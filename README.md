# Neovim Configuration

This is a streamlined Neovim setup optimized for web, Python, and Lua
development with a focus on clarity, speed, and discoverability of keymaps.

## Features & Plugins

- Theme: catppuccin (mocha flavour)
- File Explorer: nvim-tree
- Fuzzy Finding: telescope (+ file browser)
- Syntax & Highlighting: nvim-treesitter
- Statusline: lualine (catppuccin theme)
- Terminal: toggleterm (floating)
- LSP Management: mason + mason-lspconfig
- LSP Clients: lua_ls, ts_ls, pyright, html, cssls
- Completion: nvim-cmp + LuaSnip
- Formatting: conform.nvim (stylua, prettier, black, shfmt, etc.)
- Comments: Comment.nvim
- Git Integration: gitsigns.nvim
- Indentation Guides: indent-blankline.nvim
- Diagnostics UI: trouble.nvim
- Keymap Discoverability: which-key.nvim
- Autopairs: nvim-autopairs

## Installation

1. Install Neovim (v0.9+ recommended).
2. Ensure you have `git` and a C compiler for Treesitter parsers.
3. Place `init.lua` into `~/.config/nvim/init.lua`.
4. Start Neovim: it will auto-install `lazy.nvim` and all plugins.
5. Run `:Mason` to confirm language servers installed.

## Language Servers

Managed via mason-lspconfig. You can add more by editing the `ensure_installed`
list.

## Keymaps Summary

Leader key: Space (normal & visual mode only)

General:

- <Space>e Toggle file explorer
- <Space>n New file/folder (nvim-tree)
- <Space>d Delete file
- <Space>r Rename file
- <Space>c Copy file
- <Space>p Paste file
- <Space>t Toggle floating terminal
- <Space>f Format buffer (conform)
- <Space>/ Fuzzy search in current buffer

Telescope:

- <Space>ff Find files
- <Space>fg Live grep
- <Space>fb File browser
- <Space>fh Help tags

LSP (buffer local):

- gd Go to definition
- gD Go to declaration
- gr References
- gi Implementation
- K Hover docs
- <Space>rn Rename symbol
- <Space>ca Code action
- [d / ]d Prev/Next diagnostic
- <Space>dl Line diagnostics (float)
- <Space>fd Format via LSP

Trouble (Diagnostics/UI):

- <Space>xx Toggle Trouble
- <Space>xw Workspace diagnostics
- <Space>xd Document diagnostics
- <Space>xr References
- <Space>xt Type definitions
- <Space>xo Definitions

Git (gitsigns):

- ]c / [c Next/Prev hunk
- <Space>hs Stage hunk
- <Space>hr Reset hunk
- <Space>hp Preview hunk
- <Space>hb Blame line

Commenting (Comment.nvim):

- gcc Toggle comment line
- gc{motion} Comment motion

Completion & Snippets:

- <Tab> / <S-Tab> Navigate completion & snippet fields
- <CR> Confirm selection

Diagnostics:

- <Space>dl Float for line diagnostics

Terminal:

- <Space>t Toggle floating terminal

Autopairs:

- Auto insert matching characters and integrate with completion.

Which-key:

- Shows available leader keymaps when you pause after pressing Space.

## Formatting

Automatically formats on save (with fallback to LSP if configured). Use
`<Space>f` for manual formatting.

## Adding More

To add a new language server, add its name to the mason-lspconfig
`ensure_installed` list and restart.

## Suggestions for Future Enhancements

Optional add-ons:

- Persistence: `folke/persistence.nvim` for session management.
- Git UI: `tpope/vim-fugitive` or `kdheepak/lazygit.nvim`.
- Testing: `nvim-neotest/neotest` for test runners.
- Debugging: `mfussenegger/nvim-dap` + UI `rcarriga/nvim-dap-ui`.
- Performance profiling: `lewis6991/impatient.nvim` (if still helpful with your
  Neovim version).
- Spectre: `nvim-pack/nvim-spectre` for project-wide search/replace.
- Markdown preview: `iamcco/markdown-preview.nvim`.

## Troubleshooting

- If Treesitter highlights missing: run `:TSUpdate`.
- If LSP not attaching: check `:Mason` to ensure server installed.
- If formatting not working: run `:ConformInfo`.

## License

Personal configuration; adapt freely.
