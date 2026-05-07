{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./gatus.nix
    ./webdav.nix
    ./tailscale.nix
    ./fail2ban.nix
  ];
}
