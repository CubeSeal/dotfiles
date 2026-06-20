-- kanagawa colorscheme (eager).
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
  theme = "wave",
})
vim.cmd[[colorscheme kanagawa-wave]]
