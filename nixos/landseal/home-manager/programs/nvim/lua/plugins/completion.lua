-- nvim-cmp + sources (lze spec). The cmp source plugins are packadd-ed alongside.
return {
  "nvim-cmp",
  event = "InsertEnter",
  load = function(name)
    vim.cmd.packadd(name)
    vim.cmd.packadd("cmp-buffer")
    vim.cmd.packadd("cmp-path")
  end,
  after = function()
    local cmp = require('cmp')
    local select_opts = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
      sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'render-markdown' },
        { name = "buffer" },
        { name = 'path' },
      },
      window = {
        documentation = cmp.config.window.bordered()
      },
      formatting = {
        fields = { 'menu', 'abbr', 'kind' },
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
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
      },
    })
  end,
}
