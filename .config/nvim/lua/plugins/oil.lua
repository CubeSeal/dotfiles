return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config = function()
    require("oil").setup({
      -- Your custom configuration goes here
      view_options = {
        show_hidden = true, -- Show hidden files
      }
    })

    -- Key mappings for oil.nvim
    vim.keymap.set("n", "-", require("oil").open, { desc = "Open Oil" })
  end
}
