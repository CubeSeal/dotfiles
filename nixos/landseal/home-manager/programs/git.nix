{ gitUser, gitEmail}:
{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    signing = {
      key = "~/.ssh/id_ed25519-singing.pub";
      signByDefault = true;
    };
    settings = {
      user = {
        name = gitUser;
        email = gitEmail;
      };
      gpg.format = "ssh";
    };
  };

}
