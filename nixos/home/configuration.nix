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
    ./nginx.nix
    ./task.nix
    ./service
    # ./xserver.nix
  ];

  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  nix.settings.auto-optimise-store = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vhqkze = {
    isNormalUser = true;
    description = "vhqkze";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  security.sudo = {
    enable = true; # 确保 sudo 已启用
    extraConfig = ''
      Defaults timestamp_timeout=60
    '';
  };

  security.pki.certificateFiles = [
    ./secrets/rootCA.pem
  ];

  systemd.tmpfiles.rules = [
    "d /srv/docker 0755 root root -"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wezterm
    starship
    oh-my-zsh
    zoxide
    atuin
    age
    sops
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
    tree-sitter
    uv
    python314
    openssl

    htop
    btop
    iotop
    doggo
    trippy
    bandwhich
    procs
    arp-scan
    lsof
    moreutils
    killall
    witr

    lnav
    unzip
    p7zip
    unar
    jq
    aria2
    android-tools
    asciidoctor-with-extensions
    unstable.lazygit
    unstable.yazi
    unstable.tmux
    unstable.neovim
  ];

  sops = {
    defaultSopsFile = ./secrets/secret.yaml;
    age.keyFile = "${config.users.users.vhqkze.home}/.config/sops/age/keys.txt";
    gnupg.sshKeyPaths = [ ];
    age.sshKeyPaths = [ ];
    secrets = {
      "webdav" = { };
      "nginx/reader".owner = "nginx";
      "docker/grimmory" = { };
      "docker/plex" = { };
      "docker/ezbookkeeping" = { };
      "docker/tugtainer" = { };
      "garage" = { };
      "outline/secretKey".owner = "outline";
      "outline/utilsSecret".owner = "outline";
      "outline/oidcSecret".owner = "outline";
      "paperless/password".owner = "paperless";
      "paperless/env".owner = "paperless";
      "service/bark_me" = { };
      "service/bark_xz" = { };
      "service/weather" = { };
      "service/beszel_hub" = { };
      "service/beszel_agent" = { };
      "service/linkding" = { };
      "service/filebrowser" = { };
      "service/pocket-id" = { };
      "service/readeck" = { };
      "service/restic/repo" = { };
      "service/restic/password" = { };
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
  users.users.vhqkze.openssh.authorizedKeys.keys = [
    # mbp
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrcm51SikiK/ynIp6hFFvNXwCKvngpocvO0v0MAoxw/"
  ];

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
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "docker0" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
