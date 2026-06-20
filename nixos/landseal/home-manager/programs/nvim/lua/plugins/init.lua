-- Plugin loading.
--
-- Plugins themselves are provided by Nix (nixCats): the eager ones live in
-- `startupPlugins`, the lazy ones in `optionalPlugins` and are packadd-ed on
-- demand by `lze`. No plugin manager is bootstrapped here.

-- Eager (loaded at startup) {{{1
require('plugins.kanagawa')   -- colorscheme
require('plugins.oil')        -- file explorer (author advises against lazy-loading)
require('mini.icons').setup() -- icon library used by oil + render-markdown

-- Lazy-loaded via lze {{{1
require('lze').load {
  { import = 'plugins.treesitter' },
  { import = 'plugins.telescope' },
  { import = 'plugins.completion' },
  { import = 'plugins.render-markdown' },
  { import = 'plugins.codecompanion' },
}
