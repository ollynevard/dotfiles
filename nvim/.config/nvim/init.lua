--
-- Vim options
--

-- Leader
vim.g.mapleader = " "

-- Indentation
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

--
-- Plugins
--

-- Set up Lazy package manager - https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- Colour scheme - https://github.com/catppuccin/nvim
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 }, 
  -- Fuzzy finder - https://github.com/nvim-telescope/telescope.nvim
  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  -- Parser generator tool - https://github.com/nvim-treesitter/nvim-treesitter
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  -- File tree - https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  }
}
local opts = {}

require("lazy").setup(plugins, opts)

require("catppuccin").setup({
  transparent_background = true
})
vim.cmd.colorscheme("catppuccin")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = {"lua", "javascript", "php"},
  highlight = { enable = true},
  indent = { enable = true }
})

