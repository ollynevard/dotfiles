-- Ensure packer is installed
local ensure_packer = function()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  local is_installed = vim.fn.empty(vim.fn.glob(install_path)) == 0

  if not is_installed then
    vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd('packadd packer.nvim')

    return true
  end

  return false
end

local run_sync = ensure_packer()

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Source this file when it is updated and run packer sync 
vim.cmd [[
augroup packer_user_config
autocmd!
autocmd BufWritePost packer.lua source <afile> | PackerSync
augroup end
]]

-- Open Packer in a floating window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install plugins
packer.startup(function(use)
  -- Plugin manager (packer can manage itself)
  use 'wbthomason/packer.nvim'

  -- Fuzzy finder
  use { 'nvim-telescope/telescope.nvim', tag = '0.1.0', requires = 'nvim-lua/plenary.nvim' }

  -- Language parser
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- File navigation
  use 'theprimeagen/harpoon'
  use { 'nvim-tree/nvim-tree.lua', requires = 'nvim-tree/nvim-web-devicons' }

  -- Theme
  use { 'catppuccin/nvim', as = 'catppuccin' }

  -- Undo history
  use 'mbbill/undotree'

  -- Git
  use 'tpope/vim-fugitive'

  -- Text alignment
  use { 'echasnovski/mini.align', branch = 'stable' }

  -- Status line
  use { 'nvim-lualine/lualine.nvim', requires = 'nvim-tree/nvim-web-devicons' }

  -- Buffer line
  use { 'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons', after = 'catppuccin' }

  -- Language server
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  }

  if run_sync then
    packer.sync()
  end
end)

