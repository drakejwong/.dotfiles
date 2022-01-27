local status_ok, iron = pcall(require, "iron")
if not status_ok then
  return
end

local options = {
  iron_map_defaults = 0,
  iron_map_extended = 0,
}

for k, v in pairs(options) do
  vim.api.nvim_set_var(k, v)
end


-- iron.core.add_repl_definitions {
--   python = {
--     mycustom = {
--       command = {"mycmd"}
--     }
--   }
-- }

iron.core.set_config {
  preferred = {
    python = "ipython",
  }
}
