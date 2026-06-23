# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./router_core.nix
  ];

  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  nix.settings.auto-optimise-store = true;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 1 * 1024;
    }
  ];

  networking.hostName = "router"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      unstable = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
    })
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    unstable.neovim
    unstable.yazi
    unstable.atuin
    unstable.lnav
    unstable.lazygit

    nixfmt

    bat
    eza
    fd
    git
    delta
    moreutils
    oh-my-zsh
    ripgrep
    starship
    tmux
    wget
    zoxide

    gzip
    p7zip
    unar
    unzip

    arp-scan
    bandwhich
    btop
    doggo
    htop
    killall
    lsof
    nmap
    procs
    trippy
    witr
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ZDOTDIR = "$HOME/.config/zsh";
    ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ZSH_CUSTOM = "$HOME/.local/share/oh-my-zsh/custom";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      # 允许 root 登录，但【仅限密钥】，禁止密码
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [
    # mbp
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrcm51SikiK/ynIp6hFFvNXwCKvngpocvO0v0MAoxw/"
    # home
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMN/Hmy+xs11ejPDZDvQVTjBTCAPPpoOC2M7wIabhtx"
  ];

  services.beszel.agent = {
    enable = true;
    environment = {
      LISTEN = "45876";
    };
    # 事先创建 /var/lib/secrets 目录，文件权限600，内容包含 KEY 和 TOKEN 两个环境变量
    environmentFile = "/var/lib/secrets/beszel-agent.env";
  };

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
  system.stateVersion = "25.11"; # Did you read the comment?

}
