{ config, lib, pkgs, inputs, ... }:
let
  dots = ../../..;
  conf = "${dots}/.config";
  dotfile = name: { source = "${dots}/${name}"; };
  confdir = name: { source = "${conf}/${name}"; };
  gitUser = "CubeSeal";
  gitEmail = "kenndesilva1@gmail.com";
in
  {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "landseal";
  home.homeDirectory = "/home/landseal";

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".bashrc" = dotfile ".bashrc";
  };

  xdg.configFile = {
    "hypr" = confdir "hypr";
    "kitty" = confdir "kitty";
    "niri" = confdir "niri";
    "tmux" = confdir "tmux";
    "quickshell" = confdir "quickshell";
    # waybar / walker / mako are now superseded by the quickshell config above.
    # Their dotfiles are kept under .config/ as a fallback but are no longer
    # symlinked into place. Re-add the corresponding entries here to revert.
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # home.sessionVariables only reach a process that sourced hm-session-vars.sh,
  # i.e. one started from a login shell. That is fragile for the graphical
  # session: whether niri inherits them depends on sddm/niri-session re-execing
  # through $SHELL, which silently stops happening for a non-POSIX login shell.
  # Mirror them into ~/.config/environment.d instead, which the user systemd
  # manager reads at startup -- niri runs as niri.service, so it and everything
  # it spawns (e.g. the Mod+B browser bind, which runs `sh -c "$BROWSER"`)
  # inherit these regardless of shell.
  #
  # Values containing `$` are dropped: environment.d does not run a shell, so a
  # POSIX snippet like tmux's ${XDG_RUNTIME_DIR:-...} would be set verbatim.
  #
  # environment.d is read when the user manager starts, so a rebuild alone does
  # not update a running session -- re-login to pick up changes.
  systemd.user.sessionVariables = lib.filterAttrs (
    _: v: !(lib.hasInfix "$" (toString v))
  ) config.home.sessionVariables;

  home.sessionPath = [
    "$HOME/.local/bin"
  ];


  # Custom user programs
  imports = [
    ./programs/zen.nix
    ./programs/firefox.nix
    ./programs/nushell.nix
    (import ./programs/zsh.nix {dotfile=dotfile;})
    (import ./programs/git.nix {gitUser=gitUser; gitEmail=gitEmail;})
    (import ./programs/jj.nix {gitUser=gitUser; gitEmail=gitEmail;})
    ./programs/claude-code.nix
    ./programs/quickshell.nix
    ./programs/neovim.nix
  ];

  programs = {
    home-manager.enable = true;
    tmux.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    lazygit.enable = true;
    zoxide = {
      enable = true;
    };
    chromium = {
      enable = true;
      package = pkgs.chromium.override { enableWideVine = true; };
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    kitty
    grimblast
    grim          # used by the quickshell lock screen to grab a pre-lock screenshot
    fuzzel
    wl-clipboard
    fastfetch
    ripgrep
    mpv
    prismlauncher
    jjui
    overskride
    tor-browser
    brightnessctl
    calibre
    libnotify
    nodejs
    qbittorrent
    obsidian
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.
}
