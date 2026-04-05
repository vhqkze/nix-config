{
  config,
  pkgs,
  nixpkgs-unstable,
  zen-browser,
  ...
}:
{
  home.username = "vhqkze";
  home.homeDirectory = "/home/vhqkze";
  home.preferXdgDirectories = true;

  xdg.userDirs = {
    enable = true; # 启用 xdg.userDirs 模块
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
    videos = "$HOME/Videos";
  };
  # xdg.mimeApps.defaultApplications = {
  #   "x-terminal-emulator.desktop" = [ "wezterm.desktop" ];
  # };

  # xdg.terminal-exec = {
  #   enable = true;
  #   settings = {
  #     default = [ "wezterm.desktop" ];
  #   };
  # };

  # xdg.terminal-exec = {
  #   enable = true;
  #   settings = {
  #     default = [
  #       "wezterm.desktop"
  #     ];
  #   };
  # };

  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "Iosevka"
      "Symbols Nerd Font"
      "Sarasa Mono SC"
    ];
    sansSerif = [
      "Sarasa Mono SC"
      "Noto Sans CJK SC"
      "Symbols Nerd Font"
    ];
    serif = [
      "Noto Serif"
      "Symbols Nerd Font"
    ];
    emoji = [
      "Noto Color Emoji"
    ];
  };

  xdg.configFile =
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      homedir = config.home.homeDirectory;
      dotfiles = "${homedir}/Developer/dotfiles";
    in
    {
      atuin.source = link "${dotfiles}/atuin";
      bat.source = link "${dotfiles}/bat";
      ghostty.source = link "${dotfiles}/ghostty";
      git.source = link "${dotfiles}/git";
      gitui.source = link "${dotfiles}/gitui";
      hypr.source = link "${dotfiles}/hypr";
      kitty.source = link "${dotfiles}/kitty";
      lazygit.source = link "${dotfiles}/lazygit";
      nvim.source = link "${homedir}/Developer/nvim";
      starship.source = link "${dotfiles}/starship";
      stylua.source = link "${dotfiles}/stylua";
      tmux.source = link "${dotfiles}/tmux";
      waybar.source = link "${dotfiles}/waybar";
      wezterm.source = link "${dotfiles}/wezterm";
      wofi.source = link "${dotfiles}/wofi";
      yapf.source = link "${dotfiles}/yapf";
      yazi.source = link "${dotfiles}/yazi";
      zsh.source = link "${dotfiles}/zsh";
    };

  home.file.".prettierrc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/dotfiles/prettier/prettierrc.json";

  home.packages = with pkgs; [
    nixfmt-rfc-style
    wofi
    rofi
    waybar
    glow
    oh-my-zsh
    nixd
    hugo
    hexyl
    lazydocker
    pipx
    mpv

    python314
    poetry
    nodejs_24
    # nixpkgs-unstable.legacyPackages.aarch64-linux.albert
    # (pkgs.cherry-studio.overrideAttrs (oldAttrs: rec {
    #   version = "1.6.0";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "CherryHQ";
    #     repo = "cherry-studio";
    #     # rev = "v${version}";
    #     tag = "v${version}";
    #     sha256 = "";
    #   };
    # }))
  ];

  home.sessionVariables = {
    # 将 oh-my-zsh 的根路径作为环境变量传递
    ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ZSH_CUSTOM = "$HOME/.local/share/oh-my-zsh/custom";
    # HELPDIR = "${pkgs.zsh}/share/zsh/${pkgs.zsh.version}/help";
  };

  imports = [
    zen-browser.homeModules.beta
    # or inputs.zen-browser.homeModules.twilight
    # or inputs.zen-browser.homeModules.twilight-official
  ];

  programs.zen-browser.enable = true;

  # services.vicinae = {
  #   enable = true;
  #   autoStart = true;
  #   # package = vicinae.packages.${pkgs.system}.default; # 如果需要
  # };

  home.stateVersion = "25.11";
}
