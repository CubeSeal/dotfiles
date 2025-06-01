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
      theme = "dragon",
    })
    vim.cmd[[colorscheme kanagawa]]
  end
}
