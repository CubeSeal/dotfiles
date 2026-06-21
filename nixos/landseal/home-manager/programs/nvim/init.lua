-- vim:fileencoding=utf-8:foldmethod=marker
local opts = { noremap = true, silent = true }
local map = vim.keymap.set
local opt = vim.opt

-- Options {{{1
opt.number = true
opt.mouse = 'a'
opt.wrap = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.colorcolumn = "120"
vim.wo.relativenumber = true
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Remaps {{{1

-- Split navigation with Alt + hjkl
map('n', '<A-h>', '<C-w>h')
map('n', '<A-j>', '<C-w>j')
map('n', '<A-k>', '<C-w>k')
map('n', '<A-l>', '<C-w>l')

-- Folds {{{1
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevelstart = 99

-- Leader {{{1
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Autocommand {{{1
-- Highlight on Yank {{{2
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- MakeProgram {{{2

-- Haskell {{{3
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'haskell',
    group = vim.api.nvim_create_augroup('CabalBuild', { clear = true }),
    callback = function()
        vim.bo.makeprg = 'cabal build'
    end,
})

-- Diagnostics {{{2
-- vim.diagnostic.config{virtual_lines = true}

-- Diagnostic Floating window:
-- You will likely want to reduce updatetime which affects CursorHold
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
  callback = function ()
    vim.diagnostic.open_float(nil, {focus=false})
  end
})

-- LSP Enable
vim.lsp.enable('hls')
vim.lsp.enable('pyright')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('nil_ls')

-- kotlin-language-server crashes on init when storagePath resolves to nil
-- (no project root found): init_options becomes an empty Lua table, which
-- serializes to a JSON array `[]` instead of an object. Always give it a
-- concrete cache directory so initializationOptions is a non-empty object.
vim.lsp.config('kotlin_language_server', {
  init_options = {
    storagePath = vim.fn.stdpath('cache'),
  },
})
vim.lsp.enable("kotlin_language_server")

-- Configs {{{1
require("plugins")
