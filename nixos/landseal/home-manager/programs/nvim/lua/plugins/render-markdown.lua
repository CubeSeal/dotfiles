-- render-markdown.nvim (lze spec). Depends on treesitter + mini.icons (icons eager).
return {
  "render-markdown.nvim",
  ft = { "markdown", "codecompanion" },
  after = function()
    require('render-markdown').setup({
      render_modes = { 'n', 'c', 't' },
      sign = { enabled = false },
    })
  end,
}
