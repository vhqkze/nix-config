{
  config,
  pkgs,
  dockerDir,
  ...
}:
{
  sops.secrets.grimmory = { };

  virtualisation.oci-containers.containers.grimmory =
    let
      uid = "1000";
      # uid = toString config.users.users.vhqkze.uid; # 不能用这个，这个值是空的
      gid = toString config.users.groups.${config.users.users.vhqkze.group}.gid;
    in
    {
      image = "ghcr.io/grimmory-tools/grimmory:latest";
      ports = [ "6060:6060" ];
      environment = {
        USER_ID = uid;
        GROUP_ID = gid;
        TZ = config.time.timeZone;
        DATABASE_URL = "jdbc:mariadb://host.docker.internal:3306/grimmory";
        DATABASE_USERNAME = "grimmory";
        API_DOCS_ENABLED = "false";
      };
      environmentFiles = [ config.sops.secrets.grimmory.path ];
      volumes = [
        "${dockerDir}/grimmory/data:/app/data"
        "${dockerDir}/grimmory/library:/library"
        "${dockerDir}/grimmory/bookdrop:/bookdrop"
      ];
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
    };

  services.nginx.virtualHosts."book.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:6060";
      proxyWebsockets = true;
    };
    extraConfig = ''
      client_max_body_size 10G;
    '';
  };

  services.restic.backups.grimmory = {
    paths = [
      "${dockerDir}/grimmory"
      "/tmp/mariadb/grimmory.sql"
    ];
    backupPrepareCommand = ''
      install -d -m 750 -o root -g root /tmp/mariadb
      ${pkgs.mariadb}/bin/mariadb-dump --single-transaction --quick --routines --triggers --events -f grimmory > /tmp/mariadb/grimmory.sql
    '';
    backupCleanupCommand = "rm -rf /tmp/mariadb";
  };
}
