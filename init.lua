-- Basic stuff
vim.opt.number = true
vim.opt.wrap = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4 
vim.opt.expandtab = true
vim.wo.relativenumber = true
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

-- Remaps
vim.g.mapleader = ' '
local opts = { noremap = true, silent = true }
local map = vim.keymap.set

map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

-- Configs
require("config.lazy")

-- LSP
capabilities = require("cmp_nvim_lsp").default_capabilities()
require'lspconfig'.hls.setup{
    capabilities = capabilities, 
}

cmp = require('cmp')
cmp.setup{
    sources = cmp.config.sources { 
        { name = 'nvim_lsp' },
        { name = "buffer" },
        { name = 'path' }
    },
}
 
-- Treesitter
require'nvim-treesitter.configs'.setup { 
  highlight = { 
    enable = true, 
  }, 
  indent = { 
    enable = true, 
  }, 
}

-- Themes
vim.cmd[[colorscheme tokyonight]]
