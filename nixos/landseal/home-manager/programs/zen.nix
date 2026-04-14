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
      ];
      settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "zen.welcome-screen.seen" = true;
        # Enable compact mode (hides sidebar and toolbar)
        "zen.view.compact.hide-tabbar" = true;
        "zen.view.compact.hide-toolbar" = true;

        # Floating sidebar — show on hover in compact mode
        "zen.view.compact.show-sidebar-and-toolbar-on-hover" = true;

        # Remove the border around the browser window
        "zen.theme.content-element-separation" = 0;

        # Other compact mode tweaks you might want
        "zen.view.compact.animate-sidebar" = true;
        "zen.view.compact.color-sidebar" = true;
        "zen.view.compact.color-toolbar" = true;

        # Allow sideloading extensions:
        "extensions.autoDisableScopes" = 0;
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
