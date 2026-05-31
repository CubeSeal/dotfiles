{ pkgs, inputs, ... }:
{
  programs.claude-code = {
    enable = true;
    # point it at the flake's package so you keep the hourly-updated build:
    package = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      theme = "dark";
      includeCoAuthoredBy = true;
      editorMode = "vim";
      model = "opus";
      permissions = {
        allow = [ "Bash(git diff:*)" ];
        # ask = [ "Bash(git push:*)" ];
        # deny = [ "Read(./.env)" "Read(./secrets/**)" ];
      };
    };
  };
}
