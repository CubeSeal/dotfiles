# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hosts/laptop-hardware-configuration.nix
      # Nix settings
      ./nix.nix
      # User configuration
      ./users/landseal.nix
      # Windows Manager
      ./wm/niri.nix
      # ./wm/kde.nix
      # ./wm/hyprland.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # General display manager settings
  # No auto-login since this isn't encrypted.
  services.displayManager = {
    defaultSession = "niri";
  };

  # Laptop specific settings
  # Swapfile
  swapDevices = [{
      device = "/var/lib/swapfile";
      # Size in MB
      size = 16*1024; # 16 GB
  }];

  # Setup hibernation
  boot = {
    kernelParams = ["resume_offset=106133504"];
    resumeDevice = "/dev/disk/by-uuid/425ea73c-1daf-4383-b1c3-3fad8343e550";
  };
  
  # Lid switch behaviour
  services.logind.settings.Login = {
    # Suspend first then hibernate when closing the lid...
    HandleLidSwitch = "suspend-then-hibernate";
    # ... but only when on battery power.
    HandleLidSwitchDocked = "ignore";
  };

  powerManagement.powerDownCommands = ''
    # Stop the service first to release control of the hardware
    ${pkgs.systemd}/bin/systemctl stop bluetooth.service
    
    # Unload the driver. This guarantees it cannot block hibernation.
    # We use 'modprobe -r' to remove it.
    ${pkgs.kmod}/bin/modprobe -r btusb
  '';
  
  powerManagement.resumeCommands = ''
    # Reload the driver. This forces the kernel to re-detect the hardware
    # as if you just plugged it in.
    ${pkgs.kmod}/bin/modprobe btusb
    
    # Give the hardware a split second to initialize before starting the service
    sleep 1
    
    # Start the service back up
    ${pkgs.systemd}/bin/systemctl start bluetooth.service
  '';
  # Define time delay for hibernation
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';

  # TLP for power savings.
  services.tlp  = {
    enable = true;
    settings = {
      # Apparently the AI says "powersave" for scaling is better than
      # "performance". Justification: On modern Intel CPUs (using the
      # intel_pstate driver), "Powersave" does not mean "Slow." It means
      # "Dynamic." If you set the governor to Performance, your CPU will run at
      # Max Turbo (4.5 GHz) constantly, even when you are just staring at a
      # blank desktop. This creates unnecessary heat and fan noise, even if you
      # are plugged into the wall.
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Force the scaling limit to the CPU's theoretical max (4.5GHz)
      CPU_SCALING_MIN_FREQ_ON_AC = 400000;
      CPU_SCALING_MAX_FREQ_ON_AC = 4500000;

      # Do the same for battery if you want boost on battery
      CPU_SCALING_MIN_FREQ_ON_BAT = 400000;
      CPU_SCALING_MAX_FREQ_ON_BAT = 4500000;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # PLATFORM_PROFILE_ON_AC = "performance";
      # PLATFORM_PROFILE_ON_BAT = "quiet";

      # Allow the deepest sleep states for PCIe links
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # Force devices (Wifi, SSD, Graphics, NPU) to sleep when idle
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # Audio: Power down the audio chip after 10 second of silence
      # (Prevents the audio codec from keeping the bus awake)
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 10;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      # Watchdog: Disable the kernel NMI watchdog (Saves tiny % of CPU wakeups)
      NMI_WATCHDOG = 0;
    };
  };

  # Disable power-profiles-daemon to avoid conflicts with TLP.
  services.power-profiles-daemon.enable = false;

  # Nixos power saving
  powerManagement.enable = true;

  # Enable networking
  networking = {
    hostName = "nixos-laptop"; # Define your hostname.
    networkmanager.enable = true;
  };
 
  # Intel drivers for hardware acceleration.
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Critical for some apps (Steam, Wine, etc)
      extraPackages = with pkgs; [
      intel-media-driver   # LIBVA_DRIVER_NAME=iHD
        intel-compute-runtime # OpenCL support
        vpl-gpu-rt           # Video Processing Library (Gen12+)
      ];
  };

  # Force the system to use the iHD driver
  environment.sessionVariables = { 
    LIBVA_DRIVER_NAME = "iHD"; 
  };

  # Configure swayidle to manage idle and locking behavior.
  systemd.user.services.swayidle = let
    # 1. A robust script to check if we are plugged in.
    # Returns exit code 0 if on AC, 1 if on Battery.
    # We check for any power_supply starting with AC or ADP that is "online".
    checkAC = pkgs.writeShellScript "check-ac" ''
      if grep -q "1" /sys/class/power_supply/ADP*/online 2>/dev/null; then
        exit 0 # We are on AC
      else
        exit 1 # We are on Battery
      fi
    '';

    # 2. Helper to run a command ONLY if on Battery
    runOnBattery = cmd: "${checkAC} || ${cmd}";
    
    # 3. Helper to run a command ONLY if on AC
    runOnAC = cmd: "${checkAC} && ${cmd}";

    # 4. Your standard commands
    niriMsg = "${pkgs.niri}/bin/niri msg action";
    hyprlock = "pgrep hyprlock || ${pkgs.hyprlock}/bin/hyprlock &";
    systemctl = "systemctl";
    suspend_cmd = "suspend-then-hibernate";
    in {
      description = "Idle Manager for Niri";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "1s";
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout 60   '${runOnBattery "${niriMsg} power-off-monitors"}' \
            timeout 300  '${runOnBattery "${systemctl} ${suspend_cmd}"}' \
            timeout 300  '${runOnAC "${niriMsg} power-off-monitors"}' \
            timeout 900 '${runOnAC "${systemctl} ${suspend_cmd}"}' \
            resume '${niriMsg} power-on-monitors' \
            before-sleep '${hyprlock}'
        '';
      };
    };

  # Wifi: Configure with nmtui or nmcli.
  # Bluetooth: Configure with overskride (installed below).
  hardware.bluetooth.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
