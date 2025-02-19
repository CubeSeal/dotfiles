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

-- Configs
require("config.lazy")

-- LSP
capabilities = require("cmp_nvim_lsp").default_capabilities()

cmp = require('cmp')
cmp.setup{
    sources = cmp.config.sources { 
        { name = 'codecompanion' },
        { name = 'nvim_lsp' },
        { name = "buffer" },
        { name = 'path' }
    },
}

vim.diagnostic.config { virtual_text = true }

map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

-- Individual LSP setups
lsp_config = require('lspconfig')

lsp_config.hls.setup{
    capabilities = capabilities, 
}
 
lsp_config.pyright.setup{
    capabilities = capabilities, 
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

-- Telescope keybindings
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Copilot
require('copilot').setup({})

-- Code completions
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "copilot",
    },
    inline = {
      adapter = "copilot",
    },
  },
})

map({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

vim.cmd([[cab cc CodeCompanion]])
