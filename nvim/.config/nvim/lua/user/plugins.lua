local fn = vim.fn
local cmd = vim.cmd

-- Install Packer if it isn't already installed
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local is_installed = fn.empty(fn.glob(install_path)) == 0

local install = function()  
  if is_installed then
    return false;
  end

  fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  })
  cmd [[packadd packer.nvim]]
  
  return true
end

local needs_bootstrap = install()

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

return packer.startup(function(use)
  use "wbthomason/packer.nvim"
--  use "nvim-lua/popup.nvim"
--  use "nvim-lua/plenary.nvim"
--  use "windwp/nvim-autopairs"
--  use "numToStr/Comment.nvim"
--  use "kyazdani42/nvim-web-devicons"
--  use "kyazdani42/nvim-tree.lua"
--  use "akinsho/bufferline.nvim"
--  use "moll/vim-bbye"
--  use "nvim-lualine/lualine.nvim"
--  use "akinsho/toggleterm.nvim"
--  use "ahmedkhalf/project.nvim"
--  use "lewis6991/impatient.nvim"
--  use "lukas-reineke/indent-blankline.nvim"
--  use "goolord/alpha-nvim"
--  use "antoinemadec/FixCursorHold.nvim" -- This is needed to fix lsp doc highlight
--  use "folke/which-key.nvim"

  -- Language support
  use "jvirtanen/vim-hcl"
  use "pearofducks/ansible-vim"

  -- Color schemes
  use "catppuccin/nvim"

  -- Completions 
--  use "hrsh7th/nvim-cmp"
--  use "hrsh7th/cmp-buffer"
--  use "hrsh7th/cmp-path"
--  use "hrsh7th/cmp-cmdline"
--  use "saadparwaiz1/cmp_luasnip"
--  use "hrsh7th/cmp-nvim-lsp"

  -- Snippets
--  use "L3MON4D3/LuaSnip"
--  use "rafamadriz/friendly-snippets"

  -- Language server
--  use "neovim/nvim-lspconfig"
--  use "williamboman/nvim-lsp-installer"
--  use "tamago324/nlsp-settings.nvim"
--  use "jose-elias-alvarez/null-ls.nvim"

  -- Telescope
--  use "nvim-telescope/telescope.nvim"

  -- Treesitter
--  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
--  use "JoosepAlviste/nvim-ts-context-commentstring"

  -- Git
--  use "lewis6991/gitsigns.nvim"

  if needs_bootstrap then
    require("packer").sync()
  end
end)
