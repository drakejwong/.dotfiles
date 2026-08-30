local pack = require("config.pack")

local modules = {
  require("plugins.editing"),
  require("plugins.completion"),
  require("plugins.fzf"),
  require("plugins.git"),
  require("plugins.lsp"),
  require("plugins.tools"),
  require("plugins.treesitter"),
  require("plugins.ui"),
}

local specs = {}
for _, plugin in ipairs(modules) do
  vim.list_extend(specs, plugin.specs or {})
end

pack.add(specs)

for _, plugin in ipairs(modules) do
  if plugin.setup then
    plugin.setup(pack)
  end
end
