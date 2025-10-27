-- ==========================
-- Basic Options
-- ==========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
-- Space will act as leader ONLY in normal & visual modes to avoid accidental triggers while typing in insert mode.
vim.g.mapleader = " "
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true }) -- make space a leader key accelerator

-- Prevent <Space> from doing anything in insert mode (default is literal space insertion) while still allowing insertion.
-- We do NOT map insert-mode <Space>; leaving it as normal space character.

-- ==========================
-- Bootstrap lazy.nvim
-- ==========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.loop.fs_stat or vim.uv.fs_stat)(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================
-- Plugins
-- ==========================
local plugins = {

  -- === Theme ===
  { "catppuccin/nvim",            name = "catppuccin",                             priority = 1000 },

  -- === File Explorer ===
  { "nvim-tree/nvim-tree.lua",    dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- === Web Devicons ===
  { "nvim-tree/nvim-web-devicons" },

  -- === Telescope ===
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
  },

  -- === Treesitter ===
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- === Floating Terminal ===
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        direction = "float",
        shading_factor = 2,
        close_on_exit = true,
        shell = vim.o.shell,
      })
    end,
  },

  -- === Statusline ===
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
          icons_enabled = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- === Mason (LSP installer) ===
  { "williamboman/mason.nvim", build = ":MasonUpdate", config = true },

  -- === Mason LSP Config ===
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "pyright", "html", "cssls" },
      })
    end,
  },

  -- === LSP Config ===
  {
    "neovim/nvim-lspconfig",
    config = function()
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local on_attach = function(_, bufnr)
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        bufmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        bufmap("n", "gr", vim.lsp.buf.references, "References")
        bufmap("n", "gi", vim.lsp.buf.implementation, "Implementation")
        bufmap("n", "K", vim.lsp.buf.hover, "Hover docs")
        bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        bufmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        bufmap("n", "<leader>dl", function() vim.diagnostic.open_float(nil, { focus = false }) end, "Line diagnostics")
        bufmap("n", "<leader>fd", function() vim.lsp.buf.format({ async = true }) end, "Format via LSP")
      end

      local servers = { "lua_ls", "ts_ls", "pyright", "html", "cssls" }

      -- Prefer new API if available (Neovim 0.11+), fallback to lspconfig for older versions.
      local has_new_api = vim.fn.has("nvim-0.11") == 1 and vim.lsp and vim.lsp.config
      if has_new_api then
        for _, name in ipairs(servers) do
          local cfg = vim.lsp.config[name] or {}
          -- Merge our settings
          cfg.capabilities = capabilities
          cfg.on_attach = on_attach
          vim.lsp.start(cfg)
        end
      else
        local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
        if ok_lspconfig then
          for _, name in ipairs(servers) do
            lspconfig[name].setup({ capabilities = capabilities, on_attach = on_attach })
          end
        end
      end
    end,
  },

  -- === Autocompletion ===
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local autopairs_cmp = require("nvim-autopairs.completion.cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
      cmp.event:on("confirm_done", autopairs_cmp.on_confirm_done())
    end,
  },
  -- === Formatter ===
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          python = { "black" },
          sh = { "shfmt" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format Document" })
    end,
  },

  -- === Which-key ===
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },

  -- === Comment.nvim ===
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup()
    end,
  },

  -- === Gitsigns ===
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "▁" },
          topdelete = { text = "▔" },
          changedelete = { text = "│" },
        },
      })
    end,
  },

  -- === Indent guides ===
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = { scope = { enabled = true }, indent = { char = "│" } },
  },

  -- === Trouble ===
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
  },

  -- === Autopairs ===
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({})
    end,
  },
}

require("lazy").setup(plugins)

-- ==========================
-- Catppuccin Theme
-- ==========================
local ok, catppuccin = pcall(require, "catppuccin")
if ok then
  catppuccin.setup({
    flavour = "mocha",
    integrations = {
      telescope = true,
      treesitter = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
        },
        underlines = { errors = { "underline" } },
      },
    },
  })
  vim.cmd.colorscheme("catppuccin")
end

-- ==========================
-- Treesitter Setup
-- ==========================
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "vim", "bash", "python", "javascript", "typescript", "html", "css" },
  highlight = { enable = true },
})

-- ==========================
-- Telescope Setup
-- ==========================
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    prompt_prefix = "  ",
    selection_caret = " ",
    path_display = { "smart" },
    layout_config = { horizontal = { preview_width = 0.6 } },
  },
  pickers = { find_files = { hidden = true } },
})

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope file_browser<CR>", { desc = "File Browser" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })

-- ==========================
-- Nvim-tree Setup
-- ==========================
local api = require("nvim-tree.api")

require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = true,
  sort_by = "name",
  view = { width = 30, side = "left" },
  renderer = { icons = { show = { file = true, folder = true, git = true } } },
  actions = { open_file = { quit_on_open = false, resize_window = true } },
})

vim.keymap.set("n", "<leader>e", api.tree.toggle, { desc = "Toggle File Explorer" })
vim.keymap.set("n", "<leader>n", api.fs.create, { desc = "New File/Folder" })
vim.keymap.set("n", "<leader>d", api.fs.remove, { desc = "Delete File" })
vim.keymap.set("n", "<leader>r", api.fs.rename, { desc = "Rename File" })
vim.keymap.set("n", "<leader>c", api.fs.copy.node, { desc = "Copy File" })
vim.keymap.set("n", "<leader>p", api.fs.paste, { desc = "Paste File" })

-- ==========================
-- Floating Terminal
-- ==========================
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle Floating Terminal" })

-- ==========================
-- Keymaps / Shortcuts Summary
-- ==========================
-- General
-- <Space>         Leader (normal/visual only)
-- <leader>e       Toggle file explorer (nvim-tree)
-- <leader>n       New file/folder (nvim-tree)
-- <leader>d       Delete file (nvim-tree)
-- <leader>r       Rename file (nvim-tree)
-- <leader>c       Copy file (nvim-tree)
-- <leader>p       Paste file (nvim-tree)
-- <leader>t       Toggle floating terminal (toggleterm)
-- <leader>f       Format buffer (conform)
-- <leader>/       Fuzzy find in current buffer (telescope builtin mapping)

-- Telescope
-- <leader>ff      Find files
-- <leader>fg      Live grep
-- <leader>fb      File browser
-- <leader>fh      Help tags

-- LSP (per-buffer when LSP attaches)
-- gd              Go to definition
-- gD              Go to declaration
-- gr              References
-- gi              Implementation
-- K               Hover docs
-- <leader>rn      Rename symbol
-- <leader>ca      Code action
-- [d / ]d         Prev/Next diagnostic
-- <leader>dl      Line diagnostics (floating window)
-- <leader>fd      Format via LSP

-- Diagnostics / Lists
-- :Trouble        Open Trouble list
-- <leader>xx      Toggle Trouble (all diagnostics)
-- <leader>xw      Workspace diagnostics
-- <leader>xd      Document diagnostics
-- <leader>xr      LSP references
-- <leader>xt      LSP type definitions
-- <leader>xo      LSP definitions

-- Git (gitsigns)
-- ]c / [c         Next/Prev hunk
-- <leader>hs      Stage hunk
-- <leader>hr      Reset hunk
-- <leader>hp      Preview hunk
-- <leader>hb      Blame line (full popup)

-- Comment.nvim
-- gc{motion}      Toggle comment for motion
-- gcc             Toggle comment for current line

-- Autopairs
-- Automatically inserts matching pairs; integrates with completion (after cmp confirm once integration added).

-- Which-key
-- Displays available keybindings after pressing leader.

-- Additional recommended (not yet mapped):
-- <leader>gs      Open Git status (can integrate with fugitive/lazygit later)

-- Setup extra keymaps for Trouble & gitsigns below.

-- Trouble keymaps
vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Trouble Toggle" })
vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end,
  { desc = "Trouble Workspace" })
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end,
  { desc = "Trouble Document" })
vim.keymap.set("n", "<leader>xr", function() require("trouble").toggle("lsp_references") end,
  { desc = "Trouble References" })
vim.keymap.set("n", "<leader>xt", function() require("trouble").toggle("lsp_type_definitions") end,
  { desc = "Trouble Type Defs" })
vim.keymap.set("n", "<leader>xo", function() require("trouble").toggle("lsp_definitions") end,
  { desc = "Trouble Definitions" })

-- Gitsigns keymaps (only if loaded)
local gs_ok, gitsigns = pcall(require, "gitsigns")
if gs_ok then
  vim.keymap.set("n", "]c", function()
    if vim.wo.diff then return "]c" end
    gitsigns.next_hunk()
  end, { desc = "Next Git Hunk" })
  vim.keymap.set("n", "[c", function()
    if vim.wo.diff then return "[c" end
    gitsigns.prev_hunk()
  end, { desc = "Prev Git Hunk" })
  vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage Hunk" })
  vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset Hunk" })
  vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview Hunk" })
  vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, { desc = "Blame Line" })
end
