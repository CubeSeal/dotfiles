return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8', -- or,   branch = '0.1.x',
  cmd = {
    'Telescope',
    'TelescopeFindFiles',
    'TelescopeLiveGrep',
    'TelescopeBuffers',
    'TelescopeHelpTags',
  },
  dependencies = { 'nvim-lua/plenary.nvim' }
}
