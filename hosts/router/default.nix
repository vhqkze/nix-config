# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./router_core.nix
    "${inputs.self}/modules/nixos/common.nix"
    "${inputs.self}/modules/services/avahi.nix"
    "${inputs.self}/modules/services/beszel-agent.nix"
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
    priority = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2 * 1024;
      priority = 3;
    }
  ];

  boot.kernel.sysctl = {
    # 调高 swappiness，让内核更积极地把冷页面压进 ZRAM
    "vm.swappiness" = 150;
    # 降低页面水印比例，对小内存机器更友好
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0; # ZRAM 推荐单页交换，减少延迟
  };

  # 防假死：建议配置 earlyoom 或开启 systemd-oomd
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # 内存剩余低于 5% 时快速杀掉进程，防止整机失去响应
  };

  networking.hostName = "router"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    arp-scan
    bandwhich
    doggo
    nmap
    procs
    trippy
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # mbp
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrcm51SikiK/ynIp6hFFvNXwCKvngpocvO0v0MAoxw/"
    # home
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMN/Hmy+xs11ejPDZDvQVTjBTCAPPpoOC2M7wIabhtx"
  ];

  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
