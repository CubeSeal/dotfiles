return {
  'rebelot/kanagawa.nvim',
  lazy=false,
  priority=1000,
  config = function()
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
  end
}
