local M = {
  specs = {
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/folke/lazydev.nvim" },
    { src = "https://github.com/b0o/SchemaStore.nvim" },
  },
}

local typescript_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
local typescript_servers = {
  effect_tsgo = { command = "effect-tsgo", probe = "effect-tsgo" },
  tsc = { command = "tsc", probe = "typescript-7" },
  vtsls = { command = "vtsls", probe = "project" },
  ts_ls = { command = "typescript-language-server", probe = "project" },
}
local typescript_root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
local servers = {
  lua_ls = { command = "lua-language-server", filetypes = { "lua" } },
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
root=$1
command=$2
mode=$3

find_project_command() {
  project_command=${1:-$command}
  dir=$root
  while :; do
    if [ -x "$dir/node_modules/.bin/$project_command" ]; then
      printf '%s\n' "$dir/node_modules/.bin/$project_command"
      return 0
    fi
    [ -e "$dir/.git" ] || [ -e "$dir/.jj" ] || [ "$dir" = / ] || {
      dir=${dir%/*}
      [ -n "$dir" ] || dir=/
      continue
    }
    return 1
  done
}

if [ "$mode" = typescript-7 ]; then
  found_local=false
  for candidate in tsc tsgo; do
    path=$(find_project_command "$candidate") || continue
    found_local=true
    version=$("$path" --version 2>/dev/null) || continue
    major=$(printf '%s\n' "$version" | sed -n 's/[^0-9]*\([0-9][0-9]*\).*/\1/p')
    if [ -n "$major" ] && [ "$major" -ge 7 ]; then
      printf '%s\n' "$path"
      exit 0
    fi
  done
  $found_local && exit 1
  for candidate in tsc tsgo; do
    path=$(command -v "$candidate") || continue
    version=$("$path" --version 2>/dev/null) || continue
    major=$(printf '%s\n' "$version" | sed -n 's/[^0-9]*\([0-9][0-9]*\).*/\1/p')
    if [ -n "$major" ] && [ "$major" -ge 7 ]; then
      printf '%s\n' "$path"
      exit 0
    fi
  done
  exit 1
elif [ "$mode" = effect-tsgo ]; then
  path=$(find_project_command) || exit 1
elif [ "$mode" != path ]; then
  path=$(find_project_command) || path=$(command -v "$command") || exit 1
else
  path=$(command -v "$command") || exit 1
fi

if [ "$command" = rust-analyzer ]; then
  rustup=$(command -v rustup || true)
  if [ -n "$rustup" ] && [ "$path" -ef "$rustup" ]; then
    exec "$rustup" which rust-analyzer
  fi
elif [ "$mode" = effect-tsgo ]; then
  exec "$path" get-exe-path
fi

printf '%s\n' "$path"
]]

local function executable(command, cwd, mode, callback)
  mode = mode or "path"
  local key = table.concat({ command, cwd, mode }, "\0")
  if executable_cache[key] ~= nil then
    callback(executable_cache[key])
    return
  end
  if executable_waiters[key] then
    executable_waiters[key][#executable_waiters[key] + 1] = callback
    return
  end
  executable_waiters[key] = { callback }

  vim.system(
    { "/bin/sh", "-c", probe_script, "nvim-lsp-probe", cwd, command, mode },
    { cwd = cwd, text = true },
    function(result)
      vim.schedule(function()
        local path = result.code == 0 and vim.trim(result.stdout or "") or ""
        executable_cache[key] = path ~= "" and path or false
        local waiters = executable_waiters[key]
        executable_waiters[key] = nil
        for _, waiter in ipairs(waiters) do
          waiter(executable_cache[key])
        end
      end)
    end
  )
end

local function project_node_module(root, ...)
  local dir = root
  local parts = { ... }
  while dir do
    local candidate = vim.fs.joinpath(dir, "node_modules", unpack(parts))
    if vim.uv.fs_stat(candidate) then
      return candidate
    end
    if vim.uv.fs_stat(vim.fs.joinpath(dir, ".git")) or vim.uv.fs_stat(vim.fs.joinpath(dir, ".jj")) then
      break
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end
end

local function attach(event)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
  end

  map("gd", function()
    require("plugins.fzf").run("lsp_definitions")
  end, "Definition")
  map("gr", function()
    require("plugins.fzf").run("lsp_references")
  end, "References")
  map("gI", function()
    require("plugins.fzf").run("lsp_implementations")
  end, "Implementation")
  map("gy", function()
    require("plugins.fzf").run("lsp_typedefs")
  end, "Type definition")
  map("<leader>ss", function()
    require("plugins.fzf").run("lsp_document_symbols")
  end, "Document symbols")
  map("<leader>sS", function()
    require("plugins.fzf").run("lsp_live_workspace_symbols")
  end, "Workspace symbols")
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

  local typescript_cache = {}
  local typescript_waiters = {}
  local typescript_preference = { "effect_tsgo", "tsc", "vtsls", "ts_ls" }

  local function start_typescript(selection, bufnr, filetype)
    if not selection or not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= filetype then
      return
    end
    if not use_lsp() then
      return
    end

    local base_name = selection.name == "effect_tsgo" and "tsc" or selection.name
    local base = vim.lsp.config[base_name]
    if not base then
      return
    end
    local config = vim.tbl_deep_extend("force", vim.deepcopy(base), {
      name = "typescript",
      root_dir = selection.root,
      filetypes = typescript_filetypes,
      capabilities = require("plugins.completion").capabilities(),
    })

    if selection.name == "effect_tsgo" or selection.name == "tsc" then
      config.cmd = { selection.path, "--lsp", "--stdio" }
    elseif selection.name == "vtsls" then
      config.cmd = { selection.path, "--stdio" }
      local effect_plugin = project_node_module(selection.root, "@effect", "language-service")
      if effect_plugin then
        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
          vtsls = {
            autoUseWorkspaceTsdk = true,
            tsserver = {
              globalPlugins = {
                {
                  name = "@effect/language-service",
                  location = effect_plugin,
                  languages = typescript_filetypes,
                  configNamespace = "typescript",
                  enableForWorkspaceTypeScriptVersions = true,
                },
              },
            },
          },
        })
      end
    else
      config.cmd = { selection.path, "--stdio" }
    end

    vim.lsp.start(config, { bufnr = bufnr })
  end

  local function configure_typescript(bufnr, filetype)
    local root = vim.fs.root(bufnr, { typescript_root_markers, { ".jj", ".git" } }) or require("config.root").get(bufnr)
    if typescript_cache[root] ~= nil then
      start_typescript(typescript_cache[root], bufnr, filetype)
      return
    end
    if typescript_waiters[root] then
      typescript_waiters[root][#typescript_waiters[root] + 1] = { bufnr = bufnr, filetype = filetype }
      return
    end

    typescript_waiters[root] = { { bufnr = bufnr, filetype = filetype } }
    local paths = {}
    local remaining = vim.tbl_count(typescript_servers)
    for name, server in pairs(typescript_servers) do
      executable(server.command, root, server.probe, function(path)
        paths[name] = path
        remaining = remaining - 1
        if remaining ~= 0 then
          return
        end

        local selection = false
        for _, candidate in ipairs(typescript_preference) do
          if paths[candidate] then
            selection = { name = candidate, path = paths[candidate], root = root }
            break
          end
        end
        typescript_cache[root] = selection
        local waiters = typescript_waiters[root]
        typescript_waiters[root] = nil
        for _, waiter in ipairs(waiters) do
          start_typescript(selection, waiter.bufnr, waiter.filetype)
        end
      end)
    end
  end

  local function configure_servers(bufnr, filetype)
    local relevant = {}
    for name, server in pairs(servers) do
      if not configured_servers[name] and vim.tbl_contains(server.filetypes, filetype) then
        relevant[name] = server
      end
    end

    if vim.tbl_contains(typescript_filetypes, filetype) then
      configure_typescript(bufnr, filetype)
    end

    if configured_servers.basedpyright then
      relevant.pyright = nil
    elseif configured_servers.pyright then
      relevant.basedpyright = nil
    end
    if vim.tbl_isempty(relevant) then
      return
    end

    local cwd = require("config.root").get(bufnr)
    local paths = {}
    local remaining = vim.tbl_count(relevant)
    for name, server in pairs(relevant) do
      executable(server.command, cwd, server.probe, function(path)
        paths[name] = path
        remaining = remaining - 1
        if remaining ~= 0 then
          return
        end
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= filetype then
          return
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
        if vim.tbl_isempty(available) or not use_lsp() then
          return
        end
        if filetype == "lua" then
          use_lazydev()
        end

        local capabilities = require("plugins.completion").capabilities()
        local enabled = {}
        for candidate, server_config in pairs(available) do
          local config = vim.tbl_deep_extend(
            "force",
            { capabilities = capabilities, filetypes = server_config.filetypes },
            server_config.config or {}
          )
          if candidate == "jsonls" and use_schemastore() then
            config.settings =
              { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } }
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
    local tools = vim.tbl_extend("force", servers, typescript_servers)
    local remaining = vim.tbl_count(tools)
    for name, server in pairs(tools) do
      executable(server.command, cwd, server.probe, function(path)
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
