-- nvim-treesitter (main branch). Eager: upstream dropped the lazy-loadable
-- `nvim-treesitter.configs` module and no longer supports lazy-loading.
-- Grammars + queries are bundled by Nix, so there is nothing to install here;
-- we just turn on highlighting (and indent) per buffer via a FileType autocmd.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_start', { clear = true }),
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
