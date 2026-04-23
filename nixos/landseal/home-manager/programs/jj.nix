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
      git.sign-on-push = true;
    };
  };

}
