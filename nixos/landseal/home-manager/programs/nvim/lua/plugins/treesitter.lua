-- nvim-treesitter (lze spec). Grammars are provided by Nix.
return {
  "nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  after = function()
    require("nvim-treesitter.configs").setup({
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
