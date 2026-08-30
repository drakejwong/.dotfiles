local M = {
  specs = {
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/folke/lazydev.nvim" },
    { src = "https://github.com/b0o/SchemaStore.nvim" },
  },
}

local typescript_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
local servers = {
  lua_ls = { command = "lua-language-server", filetypes = { "lua" } },
  tsgo = { command = "tsgo", filetypes = typescript_filetypes },
  ts_ls = { command = "typescript-language-server", filetypes = typescript_filetypes },
  basedpyright = { command = "basedpyright-langserver", filetypes = { "python" } },
  pyright = { command = "pyright-langserver", filetypes = { "python" } },
  gopls = { command = "gopls", filetypes = { "go", "gomod", "gowork", "gotmpl" } },
  rust_analyzer = {
    command = "rust-analyzer",
    filetypes = { "rust" },
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
  sqls = { command = "sqls", filetypes = { "sql", "mysql" } },
  marksman = { command = "marksman", filetypes = { "markdown", "markdown.mdx", "mdx" } },
  taplo = { command = "taplo", filetypes = { "toml" } },
  jsonls = { command = "vscode-json-language-server", filetypes = { "json", "jsonc" } },
  html = { command = "vscode-html-language-server", filetypes = { "html" } },
  cssls = { command = "vscode-css-language-server", filetypes = { "css", "less", "scss" } },
  tailwindcss = {
    command = "tailwindcss-language-server",
    filetypes = {
      "html",
      "markdown",
      "mdx",
      "css",
      "less",
      "scss",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
  },
  dockerls = { command = "docker-langserver", filetypes = { "dockerfile" } },
  docker_compose_language_service = { command = "docker-compose-langserver", filetypes = { "yaml.docker-compose" } },
  yamlls = {
    command = "yaml-language-server",
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
  },
}

local executable_cache = {}
local function executable(command)
  if executable_cache[command] ~= nil then
    return executable_cache[command]
  end
  local path = vim.fn.exepath(command)
  local available = path ~= ""
  -- rustup exposes a proxy even when the component is not installed. Asking
  -- rustup directly avoids the proxy's slow update check.
  if available and command == "rust-analyzer" then
    local realpath = vim.uv.fs_realpath(path) or path
    local rustup = vim.fn.exepath("rustup")
    local path_stat = vim.uv.fs_stat(path)
    local rustup_stat = rustup ~= "" and vim.uv.fs_stat(rustup) or nil
    local is_rustup_proxy = vim.fs.basename(realpath) == "rustup"
      or (path_stat and rustup_stat and path_stat.dev == rustup_stat.dev and path_stat.ino == rustup_stat.ino)
    if is_rustup_proxy then
      available = vim.system({ rustup ~= "" and rustup or realpath, "which", command }, { text = true }):wait().code == 0
    end
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
  local configured_servers = {}
  local use_lsp = pack.use("lsp", "nvim-lspconfig")
  local use_lazydev = pack.use("lazydev", "lazydev.nvim", function()
    require("lazydev").setup()
  end)
  local use_schemastore = pack.use("schemastore", "SchemaStore.nvim")

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

  local function configure_servers(filetype)
    local relevant = {}
    for name, server in pairs(servers) do
      if vim.tbl_contains(server.filetypes, filetype) then
        relevant[name] = server
      end
    end

    -- Prefer tsgo, then fall back to the established TypeScript server.
    if relevant.tsgo then
      if executable(servers.tsgo.command) then
        relevant.ts_ls = nil
      else
        relevant.tsgo = nil
      end
    end

    -- Prefer basedpyright when both Python type checkers are available.
    if relevant.basedpyright then
      if executable(servers.basedpyright.command) then
        relevant.pyright = nil
      else
        relevant.basedpyright = nil
      end
    end

    local available = {}
    for name, server in pairs(relevant) do
      if not configured_servers[name] and executable(server.command) then
        available[name] = server
      end
    end
    if vim.tbl_isempty(available) or not use_lsp() then return end
    if filetype == "lua" and not use_lazydev() then return end

    local capabilities = require("plugins.completion").capabilities()
    local enabled = {}
    for name, server in pairs(available) do
      local config = vim.tbl_deep_extend(
        "force",
        { capabilities = capabilities, filetypes = server.filetypes },
        server.config or {}
      )
      if name == "jsonls" and use_schemastore() then
        config.settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } }
      elseif name == "yamlls" and use_schemastore() then
        config.settings = { yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() } }
      end
      vim.lsp.config(name, config)
      configured_servers[name] = true
      enabled[#enabled + 1] = name
    end
    vim.lsp.enable(enabled)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("config_lsp_enable", { clear = true }),
    callback = function(event)
      if vim.bo[event.buf].buftype ~= "" or event.match == "" then return end
      local bufnr, filetype = event.buf, event.match

      -- Tool discovery and server startup do not need to block the file's
      -- first draw. This is especially important for missing executables on a
      -- long PATH.
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= filetype then return end
        configure_servers(filetype)
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
