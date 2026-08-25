{
  config,
  pkgs,
  inputs,
  ...
}:
{
  disabledModules = [ "services/web-apps/readeck.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/readeck.nix" ];

  services.readeck = {
    enable = true;
    package = pkgs.unstable.readeck;
    environmentFile = config.sops.secrets."service/readeck".path;
    settings = {
      main = {
        log_level = "warn";
      };
      server = {
        host = "127.0.0.1";
        port = 9020;
      };
    };
  };
}
