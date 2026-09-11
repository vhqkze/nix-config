{
  config,
  pkgs,
  inputs,
  ...
}:
{
  disabledModules = [ "services/misc/memos.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/memos.nix" ];

  services.memos = {
    enable = true;
    package = pkgs.unstable.memos;
    settings = {
      MEMOS_MODE = "prod";
      MEMOS_ADDR = "127.0.0.1";
      MEMOS_PORT = "5230";
      MEMOS_DATA = config.services.memos.dataDir;
      MEMOS_DRIVER = "sqlite";
      MEMOS_INSTANCE_URL = "https://memos.home";
    };
  };

  services.nginx.virtualHosts."memos.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${config.services.memos.settings.MEMOS_PORT}";
    };
  };

  services.restic.backups.memos = {
    paths = [ config.services.memos.dataDir ];
    backupPrepareCommand = "systemctl stop memos.service";
    backupCleanupCommand = "systemctl start memos.service";
  };
}
