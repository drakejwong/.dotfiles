-- Run from the dotfiles root: nvim --headless -u NONE -l nvim/tests/jjsigns.lua
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim/.config/nvim")
vim.g.mapleader = " "
vim.o.swapfile = false
vim.o.hidden = true
vim.o.autoread = true
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
vim.fn.writefile({ "[user]", 'name = "Test"', 'email = "test@example.com"' }, tmp .. "/jj.toml")
vim.env.JJ_CONFIG = tmp .. "/jj.toml"
vim.env.GIT_CONFIG_GLOBAL = "/dev/null"
vim.env.GIT_CONFIG_NOSYSTEM = "1"
local notices = {}
vim.notify = function(message)
  notices[#notices + 1] = message
end

local function command(cwd, args)
  local result = vim.system(args, { cwd = cwd, text = true }):wait()
  assert(result.code == 0, table.concat(args, " ") .. "\n" .. result.stderr)
  return result.stdout
end
local function jj(cwd, ...)
  return command(cwd, vim.list_extend({ "jj", "--no-pager", "--color=never" }, { ... }))
end
local function wait(label, test)
  assert(vim.wait(8000, test, 20), label .. "\n" .. table.concat(notices, "\n"))
  print("PASS: " .. label)
end
local function edit(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  return vim.api.nvim_get_current_buf()
end
local function keys(text)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(text, true, false, true), "xt", false)
end
local function event(name)
  vim.api.nvim_exec_autocmds(name, { buffer = vim.api.nvim_get_current_buf() })
end
local base = { "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten" }
local changed = vim.deepcopy(base)
changed[2], changed[9] = "TWO changed", "NINE changed"
local function fixture(name, colocate)
  local root = tmp .. "/" .. name
  vim.fn.mkdir(root, "p")
  jj(root, "git", "init", colocate and "--colocate" or "--no-colocate")
  vim.fn.writefile(base, root .. "/test.txt")
  jj(root, "new", "-m", "current")
  vim.fn.writefile(changed, root .. "/test.txt")
  jj(root, "status")
  return root
end

local ok, err = xpcall(function()
  require("plugins.git").setup(require("config.pack"))
  local root = fixture("colocated", true)
  local buf = edit(root .. "/test.txt")
  local mini = require("mini.diff")
  local signs = require("config.jjsigns")
  local function state()
    return mini.get_buf_data(buf)
  end
  wait("jj preferred over Git in colocated repo", function()
    local d = state()
    return d and d.ref_text == table.concat(base, "\n") .. "\n" and #d.hunks == 2
  end)
  assert(not vim.b[buf].gitsigns_head)
  assert(vim.fn.maparg("<leader>ghs", "n") == "", "No staging map in jj buffers")
  local commands = vim.api.nvim_get_commands({ builtin = false })
  assert(commands.JJSignsRefresh, "Baseline refresh command must remain")
  for _, name in ipairs({ "JJSigns", "JJSignsBase", "JJSignsRange", "JJSignsReset" }) do
    assert(not commands[name], "Removed comparison command must not return: " .. name)
  end
  for _, key in ipairs({ "<leader>ghc", "<leader>gh0" }) do
    assert(vim.fn.maparg(key, "n") == "", "Removed comparison key must not return: " .. key)
  end
  assert(not package.loaded["config.jjpicker"])
  print("PASS: only baseline jj commands and mappings remain")
  local op = jj(root, "--ignore-working-copy", "op", "log", "--no-graph", "-n", "1", "-T", "id")
  vim.api.nvim_buf_set_lines(buf, 4, 5, false, { "UNSAVED" })
  wait("unsaved edits update hunks", function()
    return #state().hunks == 3
  end)
  signs.refresh(buf)
  vim.wait(250)
  assert(
    op == jj(root, "--ignore-working-copy", "op", "log", "--no-graph", "-n", "1", "-T", "id"),
    "Reads must not snapshot"
  )
  print("PASS: background reads do not snapshot jj")
  local saved = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "a", "b", "c", "d" })
  wait("preview debounce fixture ready", function()
    local count = 0
    for _, hunk in ipairs(state().hunks) do
      count = count + hunk.buf_count
    end
    return count == 4
  end)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "latest edit" })
  local restore_all = vim.fn.maparg("<leader>ghR", "n", false, true).callback
  restore_all()
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), { "latest edit" }))
  assert(signs.restore("operator") == "", "Stale hunks must not start a reset operator")
  print("PASS: stale hunk data cannot restore recent edits")
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  signs.preview()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      local content = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
      assert(vim.tbl_contains(content, "+latest edit") and not vim.tbl_contains(content, "+d"))
      vim.api.nvim_win_close(win, true)
    end
  end
  print("PASS: preview uses current text before the debounce timer")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, saved)
  wait("original buffer restored after debounce checks", function()
    return #state().hunks == 3
  end)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  keys("]h")
  assert(vim.fn.line(".") == 2)
  keys("]H")
  assert(vim.fn.line(".") == 9)
  keys("[H")
  assert(vim.fn.line(".") == 2)
  print("PASS: existing navigation keys")
  signs.preview()
  local found = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      local content = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
      assert(vim.tbl_contains(content, "-two") and vim.tbl_contains(content, "+TWO changed"))
      found = true
      vim.api.nvim_win_close(win, true)
    end
  end
  assert(found, "Hunk preview should open a float")
  print("PASS: cursor-local hunk preview")
  keys("<Space>ghP")
  assert(state().overlay)
  keys("<Space>ghP")
  keys("yih")
  assert(vim.fn.getreg('"') == "TWO changed\n")
  keys("<Space>ghr")
  wait("restore hunk via existing key", function()
    return vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1] == "two" and #state().hunks == 2
  end)
  vim.api.nvim_win_set_cursor(0, { 5, 0 })
  keys(".")
  wait("hunk restore supports dot-repeat", function()
    return #state().hunks == 1 and vim.api.nvim_buf_get_lines(buf, 4, 5, false)[1] == "five"
  end)
  keys("u")
  wait("dot-repeat is undoable", function()
    return #state().hunks == 2
  end)
  keys("u")
  wait("hunk restore is undoable", function()
    return #state().hunks == 3
  end)
  signs.diff_file()
  assert(#vim.api.nvim_list_tabpages() == 2 and #vim.api.nvim_tabpage_list_wins(0) == 2)
  vim.cmd.tabclose()
  assert(not vim.wo.diff, "Diff review must not leave original window in diff mode")
  print("PASS: file diff review preserves original layout")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, changed)
  vim.bo[buf].modified = false
  jj(root, "new", "-m", "next")
  event("FocusGained")
  wait("external jj new refreshes parent", function()
    return state().ref_text == table.concat(changed, "\n") .. "\n" and #state().hunks == 0
  end)
  jj(root, "edit", "@-")
  event("TermLeave")
  wait("external jj edit refreshes parent", function()
    return #state().hunks == 2
  end)
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  keys("V<Space>ghr")
  wait("visual restore uses selected lines", function()
    return #state().hunks == 1 and vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1] == "two"
  end)
  keys("u")
  wait("visual restore is undoable", function()
    return #state().hunks == 2
  end)
  keys("<Space>ghR")
  wait("restore entire buffer", function()
    return #state().hunks == 0
  end)
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), base))
  vim.bo[buf].modified = false

  local newbuf = edit(root .. "/new file.txt")
  vim.api.nvim_buf_set_lines(newbuf, 0, -1, false, { "new" })
  wait("new unsaved file has addition signs", function()
    local d = mini.get_buf_data(newbuf)
    return d and d.ref_text == "" and #d.hunks == 1 and d.hunks[1].type == "add"
  end)
  vim.bo[newbuf].modified = false
  local weird = root .. '/quote" and \\ slash.txt'
  vim.fn.writefile({ "old" }, weird)
  jj(root, "new", "-m", "literal filenames")
  local weirdbuf = edit(weird)
  vim.api.nvim_buf_set_lines(weirdbuf, 0, -1, false, { "new" })
  wait("literal filesets handle spaces, quotes, and backslashes", function()
    local d = mini.get_buf_data(weirdbuf)
    return d and d.ref_text == "old\n" and #d.hunks == 1
  end)
  vim.bo[weirdbuf].modified = false

  local plainjj = fixture("noncolocated", false)
  local plainbuf = edit(plainjj .. "/test.txt")
  wait("non-colocated jj repository", function()
    local d = mini.get_buf_data(plainbuf)
    return d and #d.hunks == 2
  end)
  local workspace = tmp .. "/workspace"
  jj(plainjj, "workspace", "add", workspace, "-r", "@-")
  local workbuf = edit(workspace .. "/test.txt")
  wait("additional jj workspace", function()
    local d = mini.get_buf_data(workbuf)
    return d and d.ref_text == table.concat(base, "\n") .. "\n" and #d.hunks == 0
  end)

  local renamedroot = fixture("renamed", true)
  assert(vim.uv.fs_rename(renamedroot .. "/test.txt", renamedroot .. "/renamed.txt"))
  jj(renamedroot, "status")
  local renamedbuf = edit(renamedroot .. "/renamed.txt")
  wait("renamed file uses its source path as the base", function()
    local d = mini.get_buf_data(renamedbuf)
    return d and d.ref_text == table.concat(base, "\n") .. "\n" and #d.hunks == 2
  end)

  local mergeroot = fixture("merge", true)
  jj(mergeroot, "new", "@-", "-m", "left")
  local left = vim.deepcopy(base)
  left[2] = "left branch"
  vim.fn.writefile(left, mergeroot .. "/test.txt")
  local leftid = vim.trim(jj(mergeroot, "log", "--no-graph", "-r", "@", "-T", "commit_id"))
  jj(mergeroot, "new", "@-", "-m", "right")
  local right = vim.deepcopy(base)
  right[9] = "right branch"
  vim.fn.writefile(right, mergeroot .. "/test.txt")
  local rightid = vim.trim(jj(mergeroot, "log", "--no-graph", "-r", "@", "-T", "commit_id"))
  jj(mergeroot, "new", leftid, rightid, "-m", "merge")
  local mergebuf = edit(mergeroot .. "/test.txt")
  local merged = vim.deepcopy(left)
  merged[9] = right[9]
  wait("merge uses the automatic merge of all parents", function()
    local d = mini.get_buf_data(mergebuf)
    return d and d.ref_text == table.concat(merged, "\n") .. "\n" and #d.hunks == 0
  end)
  merged[5] = "merge change"
  vim.fn.writefile(merged, mergeroot .. "/test.txt")
  jj(mergeroot, "status")
  vim.cmd.checktime()
  event("FocusGained")
  wait("merge's own changes remain visible", function()
    local d = mini.get_buf_data(mergebuf)
    return d and d.ref_text:find("\nfive\n", 1, true) and #d.hunks == 1
  end)

  local deletedroot = fixture("deleted", true)
  vim.fn.delete(deletedroot .. "/test.txt")
  jj(deletedroot, "status")
  local deletedbuf = edit(deletedroot .. "/test.txt")
  wait("deleted file still has its parent reference", function()
    local d = mini.get_buf_data(deletedbuf)
    return d and d.ref_text == table.concat(base, "\n") .. "\n" and #d.hunks > 0
  end)
  keys("<Space>ghR")
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(deletedbuf, 0, -1, false), base))
  vim.api.nvim_buf_set_lines(deletedbuf, 0, 2, false, {})
  wait("top-of-file deletion is a hunk", function()
    local d = mini.get_buf_data(deletedbuf)
    return #d.hunks == 1 and d.hunks[1].buf_start == 0 and d.hunks[1].buf_count == 0
  end)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  keys("<Space>ghr")
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(deletedbuf, 0, -1, false), base))
  print("PASS: top-of-file deletion can be restored")
  vim.bo[deletedbuf].modified = false

  local raceroot = fixture("async", true)
  local racebuf = edit(raceroot .. "/test.txt")
  wait("async fixture ready", function()
    local d = mini.get_buf_data(racebuf)
    return d and d.ref_text == table.concat(base, "\n") .. "\n"
  end)
  local system, delayed, intercepted = vim.system, nil, false
  vim.system = function(args, opts, callback)
    if callback and not intercepted and opts.cwd == signs.detect(racebuf) then
      intercepted = true
      return system(args, opts, function(result)
        delayed = function()
          callback(result)
        end
      end)
    end
    return system(args, opts, callback)
  end
  signs.refresh(racebuf)
  wait("first asynchronous request captured", function()
    return delayed ~= nil
  end)
  local before_reset = vim.api.nvim_buf_get_lines(racebuf, 0, -1, false)
  keys("<Space>ghR")
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(racebuf, 0, -1, false), before_reset))
  assert(signs.restore("operator") == "", "Pending refresh must block reset operators")
  print("PASS: pending revision lookup blocks restore")
  jj(raceroot, "new", "-m", "new base")
  signs.refresh(racebuf)
  wait("newer request sets the new reference", function()
    return mini.get_buf_data(racebuf).ref_text == table.concat(changed, "\n") .. "\n"
  end)
  delayed()
  vim.wait(200)
  assert(mini.get_buf_data(racebuf).ref_text == table.concat(changed, "\n") .. "\n")
  print("PASS: late response cannot replace a newer reference")
  local at_b = vim.trim(jj(raceroot, "log", "--no-graph", "-r", "@", "-T", "commit_id"))
  delayed, intercepted = nil, false
  vim.system = function(args, opts, callback)
    if callback and not intercepted and opts.cwd == signs.detect(racebuf) and vim.tbl_contains(args, "diff") then
      intercepted = true
      return system(args, opts, function(result)
        delayed = function()
          callback(result)
        end
      end)
    end
    return system(args, opts, callback)
  end
  jj(raceroot, "edit", "@-")
  signs.refresh(racebuf)
  wait("intermediate revision has cleared the reference", function()
    return delayed ~= nil and mini.get_buf_data(racebuf).ref_text == nil
  end)
  jj(raceroot, "edit", at_b)
  signs.refresh(racebuf)
  wait("returning to the original revision reloads the cleared reference", function()
    return mini.get_buf_data(racebuf).ref_text == table.concat(changed, "\n") .. "\n"
  end)
  delayed()
  vim.wait(100)
  assert(mini.get_buf_data(racebuf).ref_text == table.concat(changed, "\n") .. "\n")
  print("PASS: A-to-B-to-A revision race is safe")
  vim.system = function(args, opts, callback)
    if callback and not intercepted and opts.cwd == signs.detect(racebuf) then
      intercepted = true
      return system(args, opts, function(result)
        delayed = function()
          callback(result)
        end
      end)
    end
    return system(args, opts, callback)
  end
  delayed, intercepted = nil, false
  signs.refresh(racebuf)
  wait("detach request captured", function()
    return delayed ~= nil
  end)
  vim.api.nvim_buf_delete(racebuf, { force = true })
  delayed()
  vim.wait(200)
  vim.system = system
  assert(not vim.api.nvim_buf_is_valid(racebuf))
  print("PASS: late response after detach is ignored")

  local gitroot = plainjj .. "/nested-git"
  vim.fn.mkdir(gitroot, "p")
  command(gitroot, { "git", "init", "-q" })
  vim.fn.writefile(base, gitroot .. "/test.txt")
  command(gitroot, { "git", "add", "test.txt" })
  command(gitroot, { "git", "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "base" })
  vim.fn.writefile(changed, gitroot .. "/test.txt")
  local gitbuf = edit(gitroot .. "/test.txt")
  wait("nested Git-only repo retains Gitsigns", function()
    local hunks = require("gitsigns").get_hunks(gitbuf)
    return vim.b[gitbuf].gitsigns_head ~= nil and vim.fn.maparg("<leader>ghs", "n") ~= "" and hunks and #hunks == 2
  end)
  assert(mini.get_buf_data(gitbuf) == nil and signs.detect(gitbuf) == nil)
  assert(vim.fn.maparg("<leader>ghs", "n") ~= "")
  require("gitsigns").stage_buffer()
  wait("Git staging still works", function()
    return command(gitroot, { "git", "diff", "--cached", "--name-only" }):find("test.txt", 1, true) ~= nil
  end)

  jj(gitroot, "git", "init", "--colocate")
  event("BufEnter")
  wait("converting an open Git repo switches to jj", function()
    local d = mini.get_buf_data(gitbuf)
    return d and d.ref_text ~= nil and not vim.b[gitbuf].gitsigns_head
  end)
  assert(vim.fn.maparg("<leader>ghs", "n") == "", "Conversion must remove Git staging maps")

  local fallback = fixture("missing-jj", true)
  local executable = vim.fn.executable
  vim.fn.executable = function(name)
    return name == "jj" and 0 or executable(name)
  end
  local fallbackbuf = edit(fallback .. "/test.txt")
  wait("Gitsigns remains available when jj is missing", function()
    local hunks = require("gitsigns").get_hunks(fallbackbuf)
    return hunks and #hunks == 2 and vim.fn.maparg("<leader>ghs", "n") ~= ""
  end)
  assert(mini.get_buf_data(fallbackbuf) == nil)
  vim.fn.executable = executable

  local outside = edit(tmp .. "/outside.txt")
  vim.wait(200)
  assert(mini.get_buf_data(outside) == nil and not vim.b[outside].gitsigns_head)
  assert(vim.fn.maparg("]h", "n") == "")
  print("PASS: no VCS mappings outside repositories")
end, debug.traceback)
vim.cmd("silent! %bwipeout!")
vim.fn.delete(tmp, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print("All jj-signs checks passed")
vim.cmd("qa!")
