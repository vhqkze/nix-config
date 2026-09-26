{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    unstable.flake = inputs.nixpkgs-unstable;
  };

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

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  security.sudo = {
    enable = true; # 确保 sudo 已启用
    extraConfig = ''
      Defaults timestamp_timeout=60
      Defaults env_keep += "EDITOR"
      Defaults env_keep += "VISUAL"
    '';
  };

  security.pki.certificateFiles = [
    "${inputs.self}/secrets/common/rootCA.pem"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config = prev.config;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    _7zz
    age
    atuin
    bat
    btop
    delta
    eza
    fd
    file
    gcc
    git
    gzip
    htop
    jq
    killall
    lnav
    lsof
    mkcert
    moreutils
    oh-my-zsh
    openssl
    ripgrep
    sops
    starship
    tree-sitter
    unar
    unzip
    wget
    wget
    witr
    zoxide
    zstd

    unstable.just
    unstable.lazygit
    unstable.neovim
    unstable.tmux
    unstable.yazi
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ZDOTDIR = "$HOME/.config/zsh";
    ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ZSH_CUSTOM = "$HOME/.local/share/oh-my-zsh/custom";
  };

  services.openssh = {
    enable = true;
    settings = {
      # 允许 root 登录，但【仅限密钥】，禁止密码
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  programs.ssh = {
    knownHosts = {
      # 主机密钥，cat /etc/ssh/ssh_host_ed25519_key.pub
      router = {
        extraHostNames = [
          "10.1.1.1"
          "router.local"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaEsCdmNBzd0W3itpheBqm9Zf8GXVXPiKjx/OvfmwB2";
      };
      home = {
        extraHostNames = [
          "10.1.1.2"
          "home.local"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDa2Tau0giSaquo7mVamGcH8705ZCguPoQpHDMWfABtm";
      };
      pi = {
        extraHostNames = [
          "10.1.1.3"
          "pi.local"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvc0GFik66/7J1BbitxYOVP62G+j1o2pb2U76JY2WLz";
      };
      "mini.local" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIA6P2j+X/hAT3gziLDAC7bkaHuD2ITc4c/vdNoIdDCq";
      };
    };
    extraConfig = ''
      Host router
        HostName router.local
        User root

      Host home
        HostName home.local
        User vhqkze

      Host pi
        HostName pi.local
        User root

      Host mini
        HostName mini.local
        User vhqkze
    '';
  };

  sops = {
    defaultSopsFile = "${inputs.self}/secrets/${config.networking.hostName}/secret.yaml";
    age.keyFile = lib.mkDefault "/var/lib/sops-nix/keys.txt";
    gnupg.sshKeyPaths = [ ];
    age.sshKeyPaths = [ ];
  };

  networking.firewall.enable = true;
}
