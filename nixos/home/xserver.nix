{
  pkgs,
  ...
}:
{
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

  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
    openFirewall = true;
  };
  services.gnome.gnome-remote-desktop.enable = true;

  programs.hyprland.enable = true;

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

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
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
  };
}
