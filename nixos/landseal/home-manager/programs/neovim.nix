# vim: set tabstop=2 shiftwidth=2 expandtab:
{ inputs, ... }:
let
  utils = inputs.nixCats.utils;
in
{
  imports = [ inputs.nixCats.homeModule ];

  nixCats = {
    enable = true;
    packageNames = [ "nvim" ];
    luaPath = ./nvim;
    # build plugins against the same nixpkgs as the rest of the system
    nixpkgs_version = inputs.nixpkgs;
    addOverlays = [ (utils.standardPluginOverlay inputs) ];

    categoryDefinitions.replace = ({ pkgs, ... }: {
      # available on PATH at runtime (inside :terminal too). Includes LSPs.
      lspsAndRuntimeDeps = {
        general = with pkgs; [ ripgrep fd ];          # telescope find/grep
        haskell = with pkgs; [ haskell-language-server ];
        python  = with pkgs; [ pyright ];
        rust    = with pkgs; [ rust-analyzer ];
        nix     = with pkgs; [ nil ];
        kotlin  = with pkgs; [ kotlin-language-server ];
      };

      # loaded at startup
      startupPlugins = {
        general = with pkgs.vimPlugins; [
          lze                 # lazy-loading library (not a manager)
          kanagawa-nvim       # colorscheme
          nvim-lspconfig      # consumed by vim.lsp.enable(...)
          cmp-nvim-lsp        # must be eager so capabilities reach LSPs on init
          oil-nvim            # author advises against lazy-loading
          mini-icons          # lib used by oil + render-markdown
          plenary-nvim        # lib used by telescope + codecompanion
          # nvim-treesitter (main branch) does not support lazy-loading, so it
          # is eager. Grammars + queries are bundled here by Nix.
          (nvim-treesitter.withPlugins (p: with p; [
            haskell
            python
            rust
            nix
            kotlin
            lua
            markdown
            markdown_inline
            bash
            vim
            vimdoc
            query
          ]))
        ];
      };

      # packadd-ed on demand by lze
      optionalPlugins = {
        general = with pkgs.vimPlugins; [
          telescope-nvim
          nvim-cmp
          cmp-buffer
          cmp-path
          render-markdown-nvim
          codecompanion-nvim
        ];
      };
    });

    packageDefinitions.replace = {
      nvim = { pkgs, ... }: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = true;
          aliases = [ "vim" "vi" ];
          hosts.node.enable = true;  # node-backed tooling (codecompanion)
        };
        categories = {
          general = true;
          haskell = true;
          python = true;
          rust = true;
          nix = true;
          kotlin = true;
        };
      };
    };
  };
}
