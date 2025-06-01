return {
  'hrsh7th/cmp-nvim-lsp',
  event = 'InsertEnter',
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    -- Individual LSP setups {{{3
    lsp_config = require('lspconfig')

    lsp_config.hls.setup{
      capabilities = capabilities, 
    }

    lsp_config.pyright.setup{
      capabilities = capabilities, 
    }
  end,
}
