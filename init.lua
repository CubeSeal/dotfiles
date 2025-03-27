-- Basic stuff
vim.opt.number = true
vim.opt.wrap = true
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
local opts = { noremap = true, silent = true }
map = vim.keymap.set

-- Configs
require("config.lazy")

-- LSP
capabilities = require("cmp_nvim_lsp").default_capabilities()
cmp = require('cmp')
local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup{
    sources = cmp.config.sources { 
        { name = 'nvim_lsp' },
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
            codecompanion = '🤖',
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

-- map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

-- Diagnostic Floating window:
-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
  callback = function ()
    vim.diagnostic.open_float(nil, {focus=false})
  end
})

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
