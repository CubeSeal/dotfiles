-- Basic stuff
vim.opt.number = true
vim.opt.wrap = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4 
vim.opt.expandtab = true
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
local map = vim.keymap.set

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
require('copilot').setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    hide_during_completion = true,
    debounce = 75,
    keymap = {
      accept = "<M-l>",
      accept_word = false,
      accept_line = false,
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
      }
    },
})

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
  display = {
    action_palette = {
      width = 95,
      height = 10,
      prompt = "Prompt ", -- Prompt used for interactive LLM calls
      provider = "default", -- default|ttelescopeelescope|mini_pick
      opts = {
        show_default_actions = true, -- Show the default actions in the action palette?
        show_default_prompt_library = true, -- Show the default prompt library in the action palette?
      },
    },
  },
})

map({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

vim.cmd([[cab cc CodeCompanion]])
