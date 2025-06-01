return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = {'markdown', 'codecompanion'},
  event = 'VeryLazy',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
}
