-- This must be first, because it changes other options
if vim.fn.has('compatible') then
  vim.o.compatible = false
end

-- Load plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
end)

-- Load LSP configuration
require('lsp')

-- Basic settings
vim.o.syntax = 'on'
vim.o.filetype = 'plugin'
vim.o.indent = 'on'

-- ... rest of your init.lua ... 