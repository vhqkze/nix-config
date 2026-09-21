{
  config,
  pkgs,
  ...
}:
{
  services.linkding = {
    enable = true;
    package = pkgs.linkding;
    port = 9090;
    environmentFile = config.sops.secrets."service/linkding".path;
    settings = {
      LD_DISABLE_BACKGROUND_TASKS = "True";
      LD_DISABLE_URL_VALIDATION = "True";
    };
  };

  services.nginx.virtualHosts."link.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.linkding.port}";
    };
  };

  services.restic.backups.linkding = {
    paths = [ config.services.linkding.dataDir ];
    backupPrepareCommand = "systemctl stop linkding.service";
    backupCleanupCommand = "systemctl start linkding.service";
  };
}
