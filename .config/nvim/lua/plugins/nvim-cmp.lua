return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
    },
    opts = function()
      local cmp = require('cmp')
      local select_opts = {behavior = cmp.SelectBehavior.Select}

      return {
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
      end
}
