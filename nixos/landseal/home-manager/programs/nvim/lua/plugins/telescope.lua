-- telescope.nvim (lze spec). plenary is an eager startup plugin.
return {
  "telescope.nvim",
  cmd = "Telescope",
  keys = {
    { "<leader>ff", function() require('telescope.builtin').find_files() end, desc = 'Telescope find files' },
    { "<leader>fg", function() require('telescope.builtin').live_grep() end, desc = 'Telescope live grep' },
    { "<leader>fb", function() require('telescope.builtin').buffers() end, desc = 'Telescope buffers' },
    { "<leader>fh", function() require('telescope.builtin').help_tags() end, desc = 'Telescope help tags' },
  },
  after = function()
    require('telescope').setup { pickers = { find_files = { hidden = true } } }
  end,
}
