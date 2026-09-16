# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./basic.nix
    ./nginx.nix
    ./task.nix
    ./service
    # ./xserver.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
      priority = 3;
    }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.page-cluster" = 0;
  };

  systemd.oomd.enable = true;

  networking.hostName = "home"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  networking.firewall.trustedInterfaces = [ "docker0" ];

  systemd.tmpfiles.rules = [
    "d /srv/docker 0755 root root -"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vhqkze = {
    isNormalUser = true;
    description = "vhqkze";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrcm51SikiK/ynIp6hFFvNXwCKvngpocvO0v0MAoxw/ mbp"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMN/Hmy+xs11ejPDZDvQVTjBTCAPPpoOC2M7wIabhtx vhqkze@home"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wezterm
    kitty
    systemctl-tui
    uv
    python314

    iotop
    doggo
    trippy
    bandwhich
    procs
    arp-scan

    android-tools
    asciidoctor-with-extensions
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
