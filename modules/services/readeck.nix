{
  config,
  pkgs,
  inputs,
  ...
}:
{
  disabledModules = [ "services/web-apps/readeck.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/readeck.nix" ];

  sops.secrets.readeck = { };

  services.readeck = {
    enable = true;
    package = pkgs.unstable.readeck;
    environmentFile = config.sops.secrets.readeck.path;
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

  services.nginx.virtualHosts."readeck.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.readeck.settings.server.port}";
    };
  };

  services.restic.backups.readeck = {
    paths = [ "/var/lib/private/readeck" ];
    backupPrepareCommand = "systemctl stop readeck.service";
    backupCleanupCommand = "systemctl start readeck.service";
  };
}
