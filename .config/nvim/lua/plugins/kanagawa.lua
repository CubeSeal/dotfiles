return {
  'rebelot/kanagawa.nvim',
  event = 'BufReadPost',
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
