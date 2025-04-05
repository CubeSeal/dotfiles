-- Basic stuff
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.wrap = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4 
vim.opt.expandtab = true
vim.opt.colorcolumn = "120"
vim.wo.relativenumber = true
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99

-- Remaps
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
local opts = { noremap = true, silent = true }
map = vim.keymap.set

-- Autocommands
-- Highlight on Yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Diagnostic Floating window:
-- You will likely want to reduce updatetime which affects CursorHold
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
  callback = function ()
    vim.diagnostic.open_float(nil, {focus=false})
  end
})

-- Configs
require("config.lazy")

-- LSP
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local cmp = require('cmp')
local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup{
    sources = cmp.config.sources { 
        { name = 'nvim_lsp' },
        { name = 'render-markdown'},
        { name = "buffer" },
        { name = 'path' }
    },
    window = {
      documentation = cmp.config.window.bordered()
    },
    formatting = {
        fields = {'menu', 'abbr', 'kind'},
        format = function(entry, item)
          local menu_icon = {
            nvim_lsp = 'λ',
            buffer = 'Ω',
            path = '🖫',
          }

          item.menu = menu_icon[entry.source.name]
          return item
        end,
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
        ['<C-n>'] = cmp.mapping.select_next_item(select_opts),
        ['<CR>'] = cmp.mapping.confirm({select = false}),
        ['<Tab>'] = cmp.mapping.confirm({select = true}),
    },
}

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
require('kanagawa').setup({
    colors = {
        theme = {
            all = {
                ui = {
                    bg_gutter = "none"
                }
            }
        }
    }, 
    transparent = true,
    theme = "dragon",
})
vim.cmd[[colorscheme kanagawa]]

-- Telescope keybindings
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- AI:
local AI_FLAG = 1

if AI_FLAG == 1 then 
    require('config.AI')
end

-- Render Markdown
require('render-markdown').setup({
    file_types = {'markdown', 'codecompanion'},
    render_modes = { 'n', 'c', 't'},
    sign = {enabled = false},
})
