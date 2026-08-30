# Neovim configuration

A standalone Neovim 0.12+ configuration. It uses the built-in `vim.pack` manager and does not depend on a distribution or external plugin manager.

## Layout

- `lua/config/`: native options, keymaps, autocommands, package loading, and project roots
- `lua/plugins/`: one focused feature group per file
- `nvim-pack-lock.json`: exact plugin revisions; commit every accepted change

`vim.pack.add()` installs packages without loading their plugin scripts. `config.pack` loads them from explicit events and mappings.

## Commands

- `:Format`: format the current buffer; never runs on save
- `:Lint`: lint the current buffer; never runs automatically
- `:LspTools`: show which configured language servers are available
- `:TSInstallConfigured`: install missing configured Treesitter parsers
- `:checkhealth`: inspect Neovim and plugin dependencies

Language servers, formatters, and linters are not installed by Neovim. The configuration uses each tool when it is available and otherwise continues without it. TypeScript server discovery also checks the current project's `node_modules/.bin` directory. It prefers `effect-tsgo`, native TypeScript 7, VTSLS, and then TypeScript Language Server, in that order. A project-local VTSLS loads a project-local `@effect/language-service` when present.

Baseline executables are `git`, `rg`, `fd`, `fzf`, `tree-sitter` 0.26.1+, and a C compiler.

## Updates

Review updates interactively:

```vim
:lua vim.pack.update()
```

Write the review buffer to accept it, or quit it to reject it. Test the editor, update Treesitter parsers when `nvim-treesitter` changes, and then commit `nvim-pack-lock.json`.

After restoring an older lockfile with JJ, restore installed packages to it:

```vim
:lua vim.pack.update(nil, { offline = true, target = "lockfile" })
```
