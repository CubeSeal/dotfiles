return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = {'markdown', 'codecompanion'},
  event = 'VeryLazy',
  dependencies = { 'nvim-treesitter/nvim-treesitter'},
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    render_modes = { 'n', 'c', 't'},
    sign = {enabled = false},
  },
}
