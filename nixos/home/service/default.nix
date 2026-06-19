{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./avahi.nix
    ./beszel.nix
    ./fail2ban.nix
    ./filebrowser.nix
    ./gatus.nix
    ./readeck.nix
    ./restic.nix
    ./webdav.nix
  ];
}
