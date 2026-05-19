{ inputs, pkgs, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
    };
    profiles.default = {
      isDefault = true;
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        bitwarden
        darkreader
        cookie-autodelete
        user-agent-string-switcher
        sponsorblock
        dearrow
      ];
      settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        # Allow sideloading extensions:
        "extensions.autoDisableScopes" = 0;

        # Remove already seen welcome screen:
        "zen.welcome-screen.seen" = true;

        # Theme
        "zen.theme.content-element-separation" = 0;

        # Compact mode
        "zen.view.compact.enable-at-startup" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.view.compact.hide-toolbar" = true;
        "zen.view.compact.show-sidebar-and-toolbar-on-hover" = true;
        "zen.view.compact.animate-sidebar" = true;
        "zen.view.compact.color-sidebar" = true;
        "zen.view.compact.color-toolbar" = true;
        "zen.view.compact.toolbar-flash-popup" = true;

        # Window behaviour
        "zen.window-sync.sync-only-pinned-tabs" = true;
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";
    };
  };

  home.sessionVariables.BROWSER = "zen-beta";
}
