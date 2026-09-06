-- Local jj backend. mini.diff owns hunk calculation/rendering; Git-only buffers
-- stay with Gitsigns. Background reads never snapshot the jj working copy.
local M = {}
local states = {}
local diff
local marker = "JJ-SIGNS\0"
-- Ask jj for its actual left-hand tree, including merged parents and renames.
-- This static script receives jj's temporary file as argv; no user text is code.
local left_args = vim.json.encode({ "-c", "printf 'JJ-SIGNS\\000'; cat \"$1\"", "jjsigns", "$left" })

local function fileset(path)
  return 'root-file:"'
    .. path:gsub('[%z\1-\31\\"]', function(char)
      if char == '"' or char == "\\" then
        return "\\" .. char
      end
      return ("\\x%02x"):format(char:byte())
    end)
    .. '"'
end

function M.detect(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or name == "" then
    return
  end
  local path = vim.fn.resolve(name)
  -- Stop at a nested Git repo instead of claiming it for an outer jj workspace.
  local root = vim.fs.root(path, { { ".jj", ".git" } })
  if root and vim.uv.fs_stat(root .. "/.jj") then
    return root, path
  end
end

local function notify(message)
  vim.notify("JJ signs: " .. message, vim.log.levels.WARN)
end

local function run(root, args, callback)
  local cmd = { "jj", "--ignore-working-copy", "--no-pager", "--color=never" }
  vim.list_extend(cmd, args)
  vim.system(cmd, { cwd = root, text = true, timeout = 10000 }, function(result)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

local function valid(buf, state, generation)
  return states[buf] == state
    and state.generation == generation
    and vim.api.nvim_buf_is_loaded(buf)
    and vim.fn.resolve(vim.api.nvim_buf_get_name(buf)) == state.path
end

local function fail(buf, state, message)
  state.revision, state.tick, state.refreshing = nil, nil, false
  diff.set_ref_text(buf, nil)
  message = vim.trim(message)
  if state.error ~= message then
    notify(message)
  end
  state.error = message
end

function M.refresh(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local state = states[buf]
  if not state then
    return
  end
  state.generation = state.generation + 1
  state.refreshing = true
  local generation = state.generation
  -- Pin all reads to one immutable commit ID, not the movable @ or change ID.
  run(state.root, { "log", "--no-graph", "-r", "@", "-T", "commit_id" }, function(result)
    if not valid(buf, state, generation) then
      return
    end
    if result.code ~= 0 then
      return fail(buf, state, result.stderr)
    end
    local revision = vim.trim(result.stdout)
    if revision == state.revision then
      state.refreshing = false
      return
    end
    -- A -> B -> A must reload A if B has already cleared its reference.
    state.revision, state.tick = nil, nil
    diff.set_ref_text(buf, nil)
    local path = fileset(state.path:sub(#state.root + 2))
    local function set_reference(text)
      if text:find("\0", 1, true) then
        return fail(buf, state, "Binary reference file; signs disabled.")
      end
      state.revision, state.error, state.tick, state.refreshing = revision, nil, nil, false
      diff.set_ref_text(buf, text)
    end
    run(state.root, {
      "--config",
      'merge-tools.nvim-jjsigns.program="/bin/sh"',
      "--config",
      "merge-tools.nvim-jjsigns.diff-args=" .. left_args,
      "--config",
      'merge-tools.nvim-jjsigns.diff-invocation-mode="file-by-file"',
      "diff",
      "-r",
      revision,
      "--tool",
      "nvim-jjsigns",
      "--",
      path,
    }, function(left)
      if not valid(buf, state, generation) then
        return
      end
      if left.code ~= 0 then
        return fail(buf, state, left.stderr)
      end
      if left.stdout:sub(1, #marker) == marker then
        return set_reference(left.stdout:sub(#marker + 1))
      end
      if left.stdout ~= "" then
        return fail(buf, state, "Unexpected output from jj's diff formatter.")
      end
      -- No diff means @ equals its base. A path absent from @ as well is a new,
      -- not-yet-snapshotted buffer. Do not parse human-readable error messages.
      run(state.root, { "file", "list", "-r", revision, "--", path }, function(list)
        if not valid(buf, state, generation) then
          return
        end
        if list.code ~= 0 then
          return fail(buf, state, list.stderr)
        end
        if list.stdout == "" then
          return set_reference("")
        end
        run(state.root, { "file", "show", "-r", revision, "--", path }, function(file)
          if not valid(buf, state, generation) then
            return
          end
          if file.code ~= 0 then
            return fail(buf, state, file.stderr)
          end
          set_reference(file.stdout)
        end)
      end)
    end)
  end)
end

local function data(buf)
  if states[buf] and states[buf].refreshing then
    notify("Comparison base is refreshing; try again in a moment.")
    return
  end
  local result = diff.get_buf_data(buf)
  if not result or result.ref_text == nil then
    notify("No comparison base yet. Try :JJSignsRefresh.")
    return
  end
  return result
end

local function hunks_ready(buf)
  local state = states[buf]
  if not state or not state.revision or state.refreshing or state.tick ~= vim.b[buf].changedtick then
    notify("Hunks are refreshing; try again in a moment.")
    return false
  end
  return true
end

-- Guard both starting an operator and executing it (including dot-repeat).
function M.restore(mode)
  local buf = vim.api.nvim_get_current_buf()
  if not hunks_ready(buf) then
    return ""
  end
  if mode == "operator" then
    local keys = diff.operator("reset")
    vim.go.operatorfunc = "v:lua.require'config.jjsigns'.restore"
    return keys
  end
  diff.operator(mode)
  return ""
end

local function lines(text)
  if text == "" then
    return {}
  end
  return vim.split(text:gsub("\n$", ""), "\n", { plain = true })
end

function M.preview()
  local buf = vim.api.nvim_get_current_buf()
  local current = data(buf)
  if not current then
    return
  end
  local row = vim.fn.line(".")
  local reference = lines(current.ref_text)
  local buffer = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  -- A key can arrive before mini.diff's debounce timer. Use this exact buffer
  -- snapshot for the popup rather than indexing live lines with cached hunks.
  local opts = current.config.options
  local hunks = vim.text.diff(current.ref_text, table.concat(buffer, "\n") .. "\n", {
    result_type = "indices",
    algorithm = opts.algorithm,
    indent_heuristic = opts.indent_heuristic,
    linematch = opts.linematch,
  })
  local preview = {}
  for _, hunk in ipairs(hunks) do
    local ref_start, ref_count, buf_start, buf_count = unpack(hunk)
    local first = math.max(1, buf_start)
    local last = math.max(first, buf_start + buf_count - 1)
    if row >= first and row <= last then
      preview[#preview + 1] = ("@@ -%d,%d +%d,%d @@"):format(ref_start, ref_count, buf_start, buf_count)
      for i = ref_start, ref_start + ref_count - 1 do
        preview[#preview + 1] = "-" .. reference[i]
      end
      for i = buf_start, buf_start + buf_count - 1 do
        preview[#preview + 1] = "+" .. buffer[i]
      end
    end
  end
  if #preview == 0 then
    return notify("No hunk under cursor.")
  end
  vim.lsp.util.open_floating_preview(preview, "diff", { border = "rounded", focus_id = "jjsigns_preview" })
end

function M.diff_file()
  local buf = vim.api.nvim_get_current_buf()
  local current = data(buf)
  if not current then
    return
  end
  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines(current.ref_text))
  vim.bo[scratch].filetype = vim.bo[buf].filetype
  vim.bo[scratch].bufhidden = "wipe"
  vim.bo[scratch].modifiable = false
  vim.b[scratch].jjsigns_revision = states[buf].revision
  -- Use a separate tab so closing review does not change the editing layout.
  vim.cmd.tabnew()
  vim.api.nvim_win_set_buf(0, scratch)
  vim.cmd.diffthis()
  vim.cmd.vsplit()
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd.diffthis()
end

local function attach(buf)
  local root, path = M.detect(buf)
  if not root or vim.fn.executable("jj") == 0 then
    return false
  end
  local state = { root = root, path = path, generation = 0, maps = {} }
  states[buf] = state
  -- Also handles converting an open Git repo to jj during an editor session.
  if package.loaded.gitsigns then
    if vim.b[buf].gitsigns_head then
      for _, key in ipairs({ "<leader>ghs", "<leader>ghS", "<leader>ghu", "<leader>ghb", "<leader>ghB", "<leader>ghD" }) do
        for _, mode in ipairs({ "n", "x" }) do
          pcall(vim.keymap.del, mode, key, { buffer = buf })
        end
      end
    end
    require("gitsigns").detach(buf)
  end
  local function map(mode, key, action, desc, extra)
    vim.keymap.set(
      mode,
      key,
      action,
      vim.tbl_extend("force", {
        buffer = buf,
        silent = true,
        desc = "JJ: " .. desc,
      }, extra or {})
    )
    for _, m in ipairs(type(mode) == "table" and mode or { mode }) do
      state.maps[#state.maps + 1] = { m, key }
    end
  end
  for key, direction in pairs({ ["]h"] = "next", ["[h"] = "prev", ["]H"] = "last", ["[H"] = "first" }) do
    map("n", key, function()
      if vim.wo.diff and (direction == "next" or direction == "prev") then
        vim.cmd.normal({ direction == "next" and "]c" or "[c", bang = true })
      else
        diff.goto_hunk(direction)
      end
    end, direction .. " hunk")
  end
  map({ "o", "x" }, "ih", function()
    if hunks_ready(buf) then
      diff.textobject()
    end
  end, "Select hunk")
  map("n", "<leader>ghr", function()
    local operator = M.restore("operator")
    return operator == "" and "" or operator .. "ih"
  end, "Restore hunk", { expr = true, remap = true })
  map("x", "<leader>ghr", function()
    return M.restore("operator")
  end, "Restore selection", { expr = true })
  map("n", "<leader>ghR", function()
    if hunks_ready(buf) then
      diff.do_hunks(buf, "reset")
    end
  end, "Restore buffer")
  map("n", "<leader>ghp", M.preview, "Preview hunk")
  map("n", "<leader>ghP", function()
    diff.toggle_overlay(buf)
  end, "Toggle inline diff")
  map("n", "<leader>ghd", M.diff_file, "Diff file against change base")
  vim.schedule(function()
    if states[buf] == state then
      M.refresh(buf)
    end
  end)
end

local function detach(buf)
  local state = states[buf]
  states[buf] = nil
  if not state or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  for _, mapping in ipairs(state.maps) do
    pcall(vim.keymap.del, mapping[1], mapping[2], { buffer = buf })
  end
end

function M.setup()
  diff = require("mini.diff")
  diff.setup({
    source = { name = "jj", attach = attach, detach = detach },
    view = { style = "sign", signs = { add = "▎", change = "▎", delete = "▁" }, priority = 6 },
    delay = { text_change = 100 },
    mappings = {
      apply = "",
      reset = "",
      textobject = "",
      goto_first = "",
      goto_prev = "",
      goto_next = "",
      goto_last = "",
    },
  })
  local group = vim.api.nvim_create_augroup("config_jjsigns", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniDiffUpdated",
    callback = function(event)
      if states[event.buf] then
        states[event.buf].tick = vim.b[event.buf].changedtick
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "FileChangedShellPost" }, {
    group = group,
    callback = function(event)
      M.refresh(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave", "TermClose", "ShellCmdPost", "VimResume" }, {
    group = group,
    callback = function()
      for buf in pairs(states) do
        M.refresh(buf)
      end
    end,
  })
  vim.api.nvim_create_user_command("JJSignsRefresh", function()
    local buf = vim.api.nvim_get_current_buf()
    if states[buf] then
      states[buf].revision = nil
    end
    diff.enable(buf)
    M.refresh(buf)
  end, { desc = "Refresh jj's hunk comparison base" })
end

return M
