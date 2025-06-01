return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = {'markdown', 'codecompanion'},
  event = 'VeryLazy',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {},
  config = function()
    require('render-markdown').setup({
      render_modes = { 'n', 'c', 't' },
      sign = { enabled = false },
    })
    require('mini.icons').setup()

  end
}
