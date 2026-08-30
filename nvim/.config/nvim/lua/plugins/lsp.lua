local M = {
  specs = {
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/folke/lazydev.nvim" },
    { src = "https://github.com/b0o/SchemaStore.nvim" },
  },
}

local servers = {
  lua_ls = { command = "lua-language-server" },
  tsgo = { command = "tsgo" },
  ts_ls = { command = "typescript-language-server" },
  basedpyright = { command = "basedpyright-langserver" },
  pyright = { command = "pyright-langserver" },
  gopls = { command = "gopls" },
  rust_analyzer = {
    command = "rust-analyzer",
    config = {
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = false,
          cargo = { allFeatures = true },
          procMacro = { enable = true },
        },
      },
    },
  },
  sqls = { command = "sqls" },
  marksman = { command = "marksman" },
  taplo = { command = "taplo" },
  jsonls = { command = "vscode-json-language-server" },
  html = { command = "vscode-html-language-server" },
  cssls = { command = "vscode-css-language-server" },
  tailwindcss = { command = "tailwindcss-language-server" },
  dockerls = { command = "docker-langserver" },
  docker_compose_language_service = { command = "docker-compose-langserver" },
  yamlls = { command = "yaml-language-server" },
}

local executable_cache = {}
local function executable(command)
  if executable_cache[command] ~= nil then
    return executable_cache[command]
  end
  local path = vim.fn.exepath(command)
  local available = path ~= ""
  -- rustup can expose a proxy even when the component is not installed.
  if available and command == "rust-analyzer" then
    available = vim.system({ path, "--version" }, { text = true }):wait().code == 0
  end
  executable_cache[command] = available
  return available
end

local function attach(event)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
  end

  map("gd", function() require("plugins.fzf").run("lsp_definitions") end, "Definition")
  map("gr", function() require("plugins.fzf").run("lsp_references") end, "References")
  map("gI", function() require("plugins.fzf").run("lsp_implementations") end, "Implementation")
  map("gy", function() require("plugins.fzf").run("lsp_typedefs") end, "Type definition")
  map("<leader>ss", function() require("plugins.fzf").run("lsp_document_symbols") end, "Document symbols")
  map("<leader>sS", function() require("plugins.fzf").run("lsp_live_workspace_symbols") end, "Workspace symbols")
  map("<leader>cr", vim.lsp.buf.rename, "Rename")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("<leader>cl", vim.lsp.codelens.run, "CodeLens")

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client:supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
  end
  if client and client:supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("lsp_highlight_" .. event.buf, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = event.buf,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = group,
      buffer = event.buf,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

function M.setup(pack)
  local has_enabled_server = false

  vim.diagnostic.config({
    severity_sort = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 2, source = "if_many" },
    float = { border = "rounded", source = true },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("config_lsp_attach", { clear = true }),
    callback = attach,
  })

  pack.event("lsp", { "blink.cmp", "nvim-lspconfig", "lazydev.nvim", "SchemaStore.nvim" }, "FileType", function()
    require("lazydev").setup()
    local capabilities = require("plugins.completion").capabilities()

    -- Prefer tsgo, then fall back to the established TypeScript server.
    if executable(servers.tsgo.command) then
      servers.ts_ls = nil
    else
      servers.tsgo = nil
    end

    -- Prefer basedpyright when both Python type checkers are available.
    if executable(servers.basedpyright.command) then
      servers.pyright = nil
    else
      servers.basedpyright = nil
    end

    for name, server in pairs(servers) do
      if executable(server.command) then
        local config = vim.tbl_deep_extend("force", { capabilities = capabilities }, server.config or {})
        if name == "jsonls" then
          config.settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } }
        elseif name == "yamlls" then
          config.settings = { yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() } }
        end
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
        has_enabled_server = true
      end
    end
  end, {
    condition = function(event)
      return vim.bo[event.buf].buftype == "" and event.match ~= ""
    end,
    callback = function(event)
      -- LSPs were enabled from inside this buffer's first FileType event.
      -- Run only Neovim's native activation group once that event completes.
      vim.schedule(function()
        if has_enabled_server and vim.api.nvim_buf_is_valid(event.buf) then
          local group = vim.api.nvim_create_augroup("nvim.lsp.enable", { clear = false })
          vim.api.nvim_exec_autocmds("FileType", {
            group = group,
            buffer = event.buf,
            modeline = false,
          })
        end
      end)
    end,
  })

  vim.api.nvim_create_user_command("LspTools", function()
    local lines = { "Language server executables:" }
    for name, server in vim.spairs(servers) do
      lines[#lines + 1] = ("  %-34s %s"):format(name, executable(server.command) and server.command or "missing")
    end
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP tools" })
  end, { desc = "Show available language servers" })
end

return M
