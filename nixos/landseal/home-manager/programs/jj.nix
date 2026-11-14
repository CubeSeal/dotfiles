{ gitUser, gitEmail}:
{ pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = gitUser;
        email = gitEmail;
      };
      signing = {
        behavior = "drop";
        backend = "ssh";
        key = "~/.ssh/id_ed25519-singing.pub";
      };
      revsets.git-sign-on-push = "~signed() & mine()";
    };
  };

}
