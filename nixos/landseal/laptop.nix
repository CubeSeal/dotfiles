# vim: set tabstop=2 shiftwidth=2 expandtab:
{ config, pkgs, ... }@inputs:
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
  boot.kernelParams = ["resume_offset=106133504"];
  boot.resumeDevice = "/dev/disk/by-uuid/425ea73c-1daf-4383-b1c3-3fad8343e550";
  
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

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "quiet";

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

  # Intel IIO Sensor Hub drivers and firmware
  boot.kernelModules = [
    "intel-hid"
    "intel_ishtp_hid"
    "hid-sensor-hub"
  ];

  hardware.enableRedistributableFirmware = true;
  nixpkgs.overlays = [
    (final: prev: {
     linux-firmware = prev.linux-firmware.overrideAttrs (old: {
        # 1. Add 7zip to the build tools so we can extract the exe
       nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.p7zip ];
        # 2. Extract and copy
         postInstall = ''
           ${old.postInstall or ""}
           # Extract the specific bin file from the exe into a temp folder
           7z -y e ${inputs.hp_iio_driver} -o_driver_temp

            # Copy it to the destination
            cp _driver_temp/ishS_SI_5.8.0.7718.bin $out/lib/firmware/intel/ish/ish_lnlm_12128606.bin
         '';
         });
     })
  ];
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.sensor.iio.enable = true;

  # Configure swayidle to manage idle and locking behavior.
  systemd.user.services = {
    swayidle = {
      description = "Idle Manager for Niri";
      
      # Start this service automatically whenever Niri starts.
      wantedBy = [ "graphical-session.target" ];
      # If Niri stops (you logout), stop this service too.
      partOf = [ "graphical-session.target" ];
      # 3. CRITICAL FIX: Wait until Niri has officially started before launching
      after = [ "graphical-session.target" ];

      serviceConfig = {
        # 4. CRITICAL FIX: If it crashes (because Niri wasn't ready yet), try again.
        # This handles the split-second race condition where Niri is "active" 
        # but the socket isn't writable yet.
        Restart = "on-failure";
        RestartSec = "1s";
        # The command setup. 
        # We use ${pkgs...} to guarantee Nix finds the correct binary path.
        # EVENT 1: Turn off screen after 5 minutes (300 seconds)
        # EVENT 2: Sleep the PC after 10 minutes (600 seconds)
        # Note: This triggers the "suspend-then-hibernate" logic we set up earlier.
        # EVENT 3: Lock the screen before sleeping
        # This runs immediately if you close the lid OR if the 10min timer hits.
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout 30 '${pkgs.niri}/bin/niri msg action power-off-monitors' \
            timeout 115 '${pkgs.hyprlock}/bin/hyprlock &' \
            timeout 120 'systemctl suspend'
            before-sleep '${pkgs.hyprlock}/bin/hyprlock'
        '';
      };
    };
    # This tool listens for audio playback. If audio is playing,
    # it tells swayidle to STOP counting down.
    sway-audio-idle-inhibit = {
      description = "Prevent sleep while audio is playing";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
        Restart = "on-failure";
      };
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
