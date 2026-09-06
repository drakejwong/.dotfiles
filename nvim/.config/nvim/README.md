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

## Sessions

`persistence.nvim` saves a session per working directory (and Git branch) on exit. Press `s` on the dashboard or `<leader>qs` to restore the session for the current directory, `<leader>ql` for the most recent session from any directory, `<leader>qS` to pick one, and `<leader>qd` to skip saving on this exit.

Language servers, formatters, and linters are not installed by Neovim. The configuration uses each tool when it is available and otherwise continues without it. TypeScript server discovery also checks the current project's `node_modules/.bin` directory. It prefers `effect-tsgo`, native TypeScript 7, VTSLS, and then TypeScript Language Server, in that order. A project-local VTSLS loads a project-local `@effect/language-service` when present. Protobuf uses `buf` for the language server (`buf lsp serve`), formatter, and linter, and falls back to `protols` and `protolint` when `buf` is missing. `buf.yaml`, `buf.gen.yaml`, `buf.policy.yaml`, and `buf.lock` get the `buf-config` filetype so `buf_ls` also serves them.

Baseline executables are `git`, `rg`, `fd`, `fzf`, `tree-sitter` 0.26.1+, and a C compiler.

## Jujutsu and Git hunks

`lua/config/jjsigns.lua` is our local jj backend. It uses the already installed `mini.diff` for live signs and hunk actions. Gitsigns still handles Git-only repositories, including staging and blame. A colocated repository uses jj; a nested Git-only repository uses Git. If the `jj` executable is unavailable, Gitsigns remains the fallback.

The jj signs compare the current buffer, including unsaved edits, with the left side of `jj diff -r @`. This includes jj's merged-parent and rename handling. Reads are asynchronous and use `--ignore-working-copy`: the editor does not snapshot files or change jj history. The reference refreshes on buffer entry, save, idle, focus, and return from a terminal. `:JJSignsRefresh` forces a refresh. Failed reads clear the reference rather than leave an old restore target active.

| Key (jj buffers) | Action |
| --- | --- |
| `]h` / `[h` | Next / previous hunk |
| `]H` / `[H` | Last / first hunk |
| `<leader>ghp` | Preview the current hunk in a floating window |
| `<leader>ghP` | Toggle inline diffs throughout the buffer |
| `<leader>ghr` | Restore the current hunk or visual selection |
| `<leader>ghR` | Restore all hunks in the buffer |
| `<leader>ghd` | Compare the file with its base in a new diff tab; `:tabclose` exits |
| `ih` | Hunk text object, for example `yih` |

Restore only edits the buffer. Use `u` to undo it and `:w` to save it. Restore is blocked while the reference or hunk data is refreshing; try the key again after the signs update. There is no jj staging, blame, or history UI here; keep using the jj CLI for those operations. Git-only buffers retain their existing Gitsigns keys. Binary references are not supported. As with `mini.diff`, final-newline-only differences are not shown.

Requires `jj`, `/bin/sh`, and `cat` for jj buffers. No additional plugin or jj configuration is needed. Run the integration checks from the dotfiles root after installing the configured packages:

```sh
nvim --headless -u NONE -l nvim/tests/jjsigns.lua
```

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
