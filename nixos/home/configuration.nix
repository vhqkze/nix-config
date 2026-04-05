# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./docker.nix
    ./nginx.nix
    ./task.nix
    ./service
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  networking.hostName = "home"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # services.displayManager.gdm.autoSuspend = false;
  services.displayManager.gdm.autoSuspend = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;
  programs.hyprland.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vhqkze = {
    isNormalUser = true;
    description = "vhqkze";
    # group = "users";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  security.sudo = {
    enable = true; # 确保 sudo 已启用
    extraConfig = ''
      Defaults timestamp_timeout=60
    '';
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wezterm
    starship
    zoxide
    atuin
    age
    sops
    neovim
    git
    delta
    wget
    file
    bat
    fd
    ripgrep
    wget
    eza
    kitty
    systemctl-tui
    mkcert

    htop
    btop
    iotop
    dig
    lsof
    moreutils
    killall

    lnav
    unzip
    p7zip
    unar
    jq
    aria2
    android-tools
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lazygit
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.yazi
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tmux
  ];

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    iosevka
    nerd-fonts.symbols-only
    sarasa-gothic
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    wqy_microhei
    wqy_zenhei
    maple-mono.truetype
  ];

  sops = {
    defaultSopsFile = ./secrets/secret.yaml;
    age.keyFile = "${config.users.users.vhqkze.home}/.config/sops/age/keys.txt";
    gnupg.sshKeyPaths = [ ];
    age.sshKeyPaths = [ ];
    secrets = {
      "webdav" = { };
      "nginx/reader".owner = "nginx";
      "nginx/ssl_cert".owner = "nginx";
      "nginx/ssl_key" = {
        owner = "nginx";
        reloadUnits = [ "nginx.service" ];
      };
      "docker/grimmory" = { };
      "docker/grimmory_db" = { };
      "docker/booklore" = { };
      "docker/booklore_db" = { };
      "docker/plex" = { };
      "docker/beszel_agent" = { };
      "docker/ezbookkeeping" = { };
      "service/bark_me" = { };
      "service/bark_xz" = { };
      "service/weather" = { };
      "service/healthcheckio" = { };
      "mkcert/public_key" = {
        owner = "vhqkze";
        mode = "0644";
        path = "${config.users.users.vhqkze.home}/.local/share/mkcert/rootCA.pem";
      };
      "mkcert/private_key" = {
        owner = "vhqkze";
        mode = "0400";
        path = "${config.users.users.vhqkze.home}/.local/share/mkcert/rootCA-key.pem";
      };
    };
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ZDOTDIR = "$HOME/.config/zsh";
  };
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # services.rustdesk-server = {
  #   enable = true;
  #   openFirewall = true;
  #   relay = {
  #     enable = true;
  #   };
  #   signal = {
  #     enable = false;
  #   };
  # };

  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
    openFirewall = true;
  };
  services.gnome.gnome-remote-desktop.enable = true;

  # services.jupyter = {
  #   enable = true;
  #   ip = "0.0.0.0";
  #   port = 8000;
  #   user = "vhqkze";
  #   group = "users";
  #   command = "jupyter lab";
  #   notebookDir = "${config.users.users.vhqkze.home}/Developer/notebook";
  #   password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$A8DmIgXL7PaJDVpR3lTHtA$EKKljGoJpXZfZpyMQc9H8DRMNZDWBxoZCBMtnskB5uM";
  #   # extraPackages =[];
  #   # kernels = {
  #   #   python3 =
  #   #     let
  #   #       env = (
  #   #         pkgs.python314.withPackages (
  #   #           pythonPackages: with pythonPackages; [
  #   #             requests
  #   #             httpx
  #   #             ipykernel
  #   #           ]
  #   #         )
  #   #       );
  #   #     in
  #   #     {
  #   #       displayName = "Python 3 Jupyter kernel";
  #   #       argv = [
  #   #         "${env.interpreter}"
  #   #         "-m"
  #   #         "ipykernel_launcher"
  #   #         "-f"
  #   #         "{connection_file}"
  #   #       ];
  #   #       language = "python";
  #   #       # logo32 = "${env.sitePackages}/ipykernel/resources/logo-32x32.png";
  #   #       # logo64 = "${env.sitePackages}/ipykernel/resources/logo-64x64.png";
  #   #     };
  #   # };
  # };

  fileSystems = {
    disk = {
      device = "UUID=f12cc39d-f589-4ded-bbe0-70027d439ad7";
      mountPoint = "/mnt/disk";
      fsType = "xfs";
      options = [
        "defaults"
        "nofail"
        "x-systemd.device-timeout=5"
      ];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    80
    443
    3306
  ];
  # networking.firewall.interfaces."lo".allowedTCPPorts = [ 3306 ];
  # networking.firewall.allowedUDPPorts = [  ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
