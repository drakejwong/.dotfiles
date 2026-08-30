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
local executable_waiters = {}
local probe_script = [[
path=$(command -v "$1") || exit 1
if [ "$1" = rust-analyzer ]; then
  rustup=$(command -v rustup || true)
  if [ -n "$rustup" ] && [ "$path" -ef "$rustup" ]; then
    exec "$rustup" which rust-analyzer
  fi
fi
printf '%s\n' "$path"
]]

local function executable(command, cwd, callback)
  local key = command == "rust-analyzer" and (command .. "\0" .. cwd) or command
  if executable_cache[key] ~= nil then
    callback(executable_cache[key])
    return
  end
  if executable_waiters[key] then
    executable_waiters[key][#executable_waiters[key] + 1] = callback
    return
  end
  executable_waiters[key] = { callback }

  vim.system({ "/bin/sh", "-c", probe_script, "nvim-lsp-probe", command }, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      local path = result.code == 0 and vim.trim(result.stdout or "") or ""
      executable_cache[key] = path ~= "" and path or false
      local waiters = executable_waiters[key]
      executable_waiters[key] = nil
      for _, waiter in ipairs(waiters) do
        waiter(executable_cache[key])
      end
    end)
  end)
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

  local function configure_servers(bufnr, filetype)
    local relevant = {}
    for name, server in pairs(servers) do
      if not configured_servers[name] and vim.tbl_contains(server.filetypes, filetype) then
        relevant[name] = server
      end
    end

    if configured_servers.tsgo then
      relevant.ts_ls = nil
    elseif configured_servers.ts_ls then
      relevant.tsgo = nil
    end
    if configured_servers.basedpyright then
      relevant.pyright = nil
    elseif configured_servers.pyright then
      relevant.basedpyright = nil
    end
    if vim.tbl_isempty(relevant) then return end

    local cwd = require("config.root").get(bufnr)
    local paths = {}
    local remaining = vim.tbl_count(relevant)
    for name, server in pairs(relevant) do
      executable(server.command, cwd, function(path)
        paths[name] = path
        remaining = remaining - 1
        if remaining ~= 0 then return end
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= filetype then return end

        -- Prefer tsgo and basedpyright when their fallbacks are also present.
        if relevant.tsgo and relevant.ts_ls then
          if paths.tsgo then
            relevant.ts_ls = nil
          else
            relevant.tsgo = nil
          end
        end
        if relevant.basedpyright and relevant.pyright then
          if paths.basedpyright then
            relevant.pyright = nil
          else
            relevant.basedpyright = nil
          end
        end

        local available = {}
        for candidate, config in pairs(relevant) do
          if paths[candidate] and not configured_servers[candidate] then
            available[candidate] = config
          end
        end
        if vim.tbl_isempty(available) or not use_lsp() then return end
        if filetype == "lua" then use_lazydev() end

        local capabilities = require("plugins.completion").capabilities()
        local enabled = {}
        for candidate, server_config in pairs(available) do
          local config = vim.tbl_deep_extend(
            "force",
            { capabilities = capabilities, filetypes = server_config.filetypes },
            server_config.config or {}
          )
          if candidate == "jsonls" and use_schemastore() then
            config.settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } }
          elseif candidate == "yamlls" and use_schemastore() then
            config.settings = {
              yaml = { schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() },
            }
          end
          vim.lsp.config(candidate, config)
          configured_servers[candidate] = true
          enabled[#enabled + 1] = candidate
        end
        vim.lsp.enable(enabled)
      end)
    end
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("config_lsp_enable", { clear = true }),
    callback = function(event)
      if vim.bo[event.buf].buftype == "" and event.match ~= "" then
        configure_servers(event.buf, event.match)
      end
    end,
  })

  vim.api.nvim_create_user_command("LspTools", function()
    local cwd = require("config.root").get()
    local found = {}
    local remaining = vim.tbl_count(servers)
    for name, server in pairs(servers) do
      executable(server.command, cwd, function(path)
        found[name] = path or "missing"
        remaining = remaining - 1
        if remaining == 0 then
          local lines = { "Language server executables:" }
          for server_name, server_path in vim.spairs(found) do
            lines[#lines + 1] = ("  %-34s %s"):format(server_name, server_path)
          end
          vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP tools" })
        end
      end)
    end
  end, { desc = "Show available language servers" })
end

return M
