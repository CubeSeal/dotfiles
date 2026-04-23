{ ... }:
{
  programs.firefox = {
    enable = true;
# policies and preferences live under profiles in HM
    profiles.default = {
      isDefault = true;
      settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
    };
  };
}
