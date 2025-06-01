-- vim:fileencoding=utf-8:foldmethod=marker
local opts = { noremap = true, silent = true }
local map = vim.keymap.set
local opt = vim.opt

-- Standard Vim Options {{{1
opt.number = true
opt.mouse = 'a'
opt.wrap = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.colorcolumn = "120"
vim.wo.relativenumber = true
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Remaps {{{2
map('n', '<A-h>', '<C-w>h')
map('n', '<A-j>', '<C-w>j')
map('n', '<A-k>', '<C-w>k')
map('n', '<A-l>', '<C-w>l')

-- Folds {{{2
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevelstart = 99

-- Leader {{{2
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Autocommands {{{2
-- Highlight on Yank {{{3
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Diagnostics {{{3
vim.diagnostic.config{virtual_lines = true}
-- Diagnostic Floating window:
-- You will likely want to reduce updatetime which affects CursorHold
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
--   callback = function ()
--     vim.diagnostic.open_float(nil, {focus=false})
--   end
-- })

-- Configs {{{1
require("config.lazy")

-- LSP {{{2
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

-- Individual LSP setups {{{3
lsp_config = require('lspconfig')

lsp_config.hls.setup{
  capabilities = capabilities, 
}

lsp_config.pyright.setup{
  capabilities = capabilities, 
}

-- Treesitter {{{2
require'nvim-treesitter.configs'.setup { 
  highlight = { 
    enable = true, 
  }, 
  indent = { 
    enable = true, 
  }, 
}

-- Themes {{{2
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

-- Telescope keybindings {{{2
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- AI {{{2
-- Copilot {{{3
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

-- Code Companion {{{3
require("codecompanion").setup({
  adapters = {
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        name = "Gemini 2.5",
        scheme = {
          model = {
            default = "gemini-2.5-pro-exp-03-25",
          }
        },
        env = {
          api_key = "cmd:cat ~/gemini.apikey"
        },
      })
    end,
  },
  strategies = {
    chat = {
      adapter = "gemini",
    },
    inline = {
      adapter = "gemini",
    },
    cmd = {
      adapter = "gemini",
    },
  },
  display = {
    action_palette = {
      width = 95,
      height = 10,
      prompt = "Prompt ", -- Prompt used for interactive LLM calls
      provider = "telescope", -- default|ttelescopeelescope|mini_pick
      opts = {
        show_default_actions = true, -- Show the default actions in the action palette?
        show_default_prompt_library = true, -- Show the default prompt library in the action palette?
      },
    },
  },
})

map({ "n", "v" }, "<Leader>a", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

vim.cmd([[cab cc CodeCompanion]])

-- Render Markdown
require('render-markdown').setup({
  render_modes = { 'n', 'c', 't'},
  sign = {enabled = false},
})
