local M = {
  configured = {},
  loaded = {},
}

local function names(value)
  return type(value) == "table" and value or { value }
end

function M.add(specs)
  local ok, err = pcall(vim.pack.add, specs, { confirm = false, load = false })
  if not ok then
    vim.schedule(function()
      vim.notify("Plugin installation failed:\n" .. err, vim.log.levels.ERROR)
    end)
  end
  return ok
end

function M.load(plugins)
  for _, name in ipairs(names(plugins)) do
    if not M.loaded[name] then
      local ok, err = pcall(vim.cmd.packadd, name)
      if not ok then
        vim.notify(("Could not load %s:\n%s"):format(name, err), vim.log.levels.ERROR)
        return false
      end
      M.loaded[name] = true
    end
  end
  return true
end

function M.use(id, plugins, configure)
  return function()
    if M.configured[id] then
      return true
    end
    if not M.load(plugins) then
      return false
    end
    if configure then
      local ok, err = xpcall(configure, debug.traceback)
      if not ok then
        vim.notify(("Could not configure %s:\n%s"):format(id, err), vim.log.levels.ERROR)
        return false
      end
    end
    M.configured[id] = true
    return true
  end
end

function M.event(id, plugins, events, configure, opts)
  opts = opts or {}
  local use = M.use(id, plugins, configure)
  vim.api.nvim_create_autocmd(events, {
    group = vim.api.nvim_create_augroup("pack_" .. id, { clear = true }),
    pattern = opts.pattern,
    once = opts.once ~= false,
    callback = function(event)
      if opts.condition and not opts.condition(event) then
        return
      end
      if use() and opts.callback then
        opts.callback(event)
      end
    end,
  })
  return use
end

function M.defer(id, plugins, configure)
  local use = M.use(id, plugins, configure)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("pack_" .. id, { clear = true }),
    once = true,
    callback = function()
      vim.schedule(use)
    end,
  })
  return use
end

function M.map(id, plugins, mode, lhs, action, opts, configure)
  local use = M.use(id, plugins, configure)
  vim.keymap.set(mode, lhs, function()
    if use() then
      action()
    end
  end, opts)
  return use
end

return M
