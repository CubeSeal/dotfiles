{ ... }:
{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };
    };
  };

  # Other programs integrations
  programs.direnv.enableNushellIntegration = true; 
  programs.zoxide.enableNushellIntegration = true;
}
