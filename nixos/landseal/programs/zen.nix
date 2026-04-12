# configuration.nix
{ inputs, pkgs, ... }:

let
  zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
  zen-desktop-name = "zen.desktop";
in
{
  environment.systemPackages = [ zen ];

  # Set as default for xdg-open / MIME
  xdg.mime.defaultApplications = {
    "text/html" = zen-desktop-name;
    "x-scheme-handler/http" = zen-desktop-name;
    "x-scheme-handler/https" = zen-desktop-name;
    "application/xhtml+xml" = zen-desktop-name;
  };

  # For CLI tools that read $BROWSER
  environment.sessionVariables.BROWSER = "zen";
}
