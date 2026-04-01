# vim: set tabstop=2 shiftwidth=2 expandtab:
# To enable usb debugging for android ev.
{ ... }:
{
# Enable the ADB daemon and udev rules
  programs.adb.enable = true;

# Add your user to the adbusers group
# REPLACE "your_username" WITH YOUR ACTUAL LINUX USERNAME
  users.users.landseal.extraGroups = [ "adbusers" ];
}

