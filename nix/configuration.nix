#Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./home.nix

      # VSCode Server
      (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

	boot.kernelParams = [
		"amd-iommu=on"
    "hid_apple.fnmode=2"
    "hid_apple.swap_fn_leftctrl=1"
    "hid_apple.swap_opt_cmd=1"
	];
  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  

  networking.hostName = "sonic"; # Define your hostname.
  networking.enableIPv6 = false;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;


  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  networking.firewall.enable = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services = {
  	xserver = {
    	xkb.layout = "de";
		  enable = true;
    	xkb.variant = "";
		  displayManager.gdm = {
        enable = true;
        wayland = true;
        settings = {
          deamon = {
            AutomaticLoginEnable = true;
            AutomaticLogin = "hannes";
          };
        };
      };
	  };
	  pipewire = {
		  enable = true;
		  alsa.enable = true;
		  alsa.support32Bit = true;
		  pulse.enable = true;
	  };
	  openssh = {
		  enable = true;
		  settings = {
			  PermitRootLogin = "no";
			  PasswordAuthentication = false;
		  };
	  };
	  logind = {
		  lidSwitch = "ignore";
	  };
    vscode-server = {
      enable = true;
    };
    #fprintd = {
    #  enable = true;
    #  tod.enable = true;
    #  tod.driver = pkgs.libfprint-2-tod1-goodix-550a;
    #};
  };

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

  #nixpkgs.config.permittedInsecurePackages = [
  #  "electron-25.9.0"
  #  "electron-19.1.9"
  #];
  programs.fish.enable = true;
  users.users.hannes = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "hannes";
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "libvirt" "adbusers" "input" "users" "wireshark" ];
    hashedPassword = "$6$ymfeFZcGMIg4TXwl$UBqUfBKDrBsUDA4ZwReQbk0soGpYVMKdTyFDSXjWqxHOWy6XDEFly2UgMlSc1d5adC.orsPt3LPVeTeLVCU1B.";
    home = "/home/hannes";
    #openssh.authorizedKeys.keyFiles = [ 
    #  /home/hannes/.ssh/authorized_keys 
    #  /home/hannes/.ssh/authorized_keys2
    #];
    packages = with pkgs; [
      # language server
      lua-language-server
      nodePackages_latest.bash-language-server
      nodePackages_latest.pyright
      python3
      python311Packages.python-lsp-server
      clang-tools
      nil
      nixpkgs-fmt
      gnumake

      # System
      busybox
      usbutils
      unetbootin
      cdrtools
      virt-manager
      netcat

      # Sync (needed later)
      #rclone
      #rsync
      #syncthing
      
      # Internet
      firefox
      google-chrome
      qbittorrent

      # notes
      obsidian

      # VPN
      openvpn

      # Code
      vscode
      helix
      neovim
      vim
      kitty
      android-studio
      jetbrains.idea-ultimate

      # Terminal
      pure-prompt
      rofi-wayland
      clang-tools
      gcc
      grc
      fzf
      ripgrep
      git
      zoxide


      # Hyprland
      xdg-desktop-portal-hyprland
      hyprpaper
      hyprcursor
      hypridle
      # needed for hyprcursor conversion
      xcur2png
      xdg-utils
      waybar

      # Java
      openjdk19

      # Container
      docker
      docker-compose

      # Fringerprint support
      #fprintd-tod
      #libfprint-2-tod1-goodix-550a

      magic-wormhole

      #chat
      whatsapp-for-linux
      discord
      signal-desktop
      mattermost
      # Games
      # prismlauncher-qt5
      wine
      bottles

      # Mail 
      evolution
      protonmail-bridge

      # Themes
      gradience
      adw-gtk3
      lxappearance

      # Hardware
      netdata
      radeontop
      lm_sensors
      openrgb
      plymouth
      bottom

      # Video 
      celluloid
      kodi-wayland
      mpv

      # Images
      gimp
      feh
      libwebp
      gnome.gdm
      # Misc
      wtype # does not work on gnome
      wl-clipboard
      libqalculate

      # Reverse engineering
      radare2
      unixtools.xxd

      # latex
      texlive.combined.scheme-medium
      texlab
      ltex-ls

      # desktop things / using gnome in this case
      polkit_gnome
      # polkit
      gnome.nautilus
      gnome.sushi
      # udisks # gnome disks backend
      gnome.gnome-disk-utility
      gnome.gnome-font-viewer
      gnome.eog
      gnome.simple-scan
      gnome.adwaita-icon-theme
      # gnome.gnome-control-center

      # libs
      imlib2Full
      wireshark

      # window manager tools
      gammastep
      swaybg
      pavucontrol
      brightnessctl
      libnotify
      dunst
      # screenshot stack 
      grim
      slurp
      swappy
      gparted

      # Music
      spotify
];
  };
  
  programs.adb.enable = true;

  programs.hyprland.enable = true;

  programs.dconf.enable = true;

  programs.wireshark.enable = true;

	xdg.portal.wlr.enable = false; 
	xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Iosevka" "DroidSansMono" "GeistMono" ]; })
  	iosevka
	  cantarell-fonts
    font-awesome_5
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
  system.stateVersion = "22.11"; # Did you read the comment?
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
          )
        )
      {
        return polkit.Result.YES;
      }
    })
    polkit.addRule(function (action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll") {
        return subject.isInGroup("input") ? polkit.Result.YES : polkit.result.NO
      }
    })
  '';

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };
  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
  };
}
