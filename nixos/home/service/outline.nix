{
  config,
  pkgs,
  ...
}:
{
  services.outline = {
    enable = true;
    port = 9050;
    publicUrl = "https://outline.home";
    defaultLanguage = "zh_CN";
    databaseUrl = "local";
    redisUrl = "local";
    maximumImportSize = 5120000;
    secretKeyFile = config.sops.secrets."outline/secretKey".path;
    utilsSecretFile = config.sops.secrets."outline/utilsSecret".path;
    storage = {
      storageType = "local";
    };
    oidcAuthentication = {
      authUrl = "https://pocket-id.home/authorize";
      clientId = "outline";
      clientSecretFile = config.sops.secrets."outline/oidcSecret".path;
      displayName = "PocketID";
      tokenUrl = "https://pocket-id.home/api/oidc/token";
      userinfoUrl = "https://pocket-id.home/api/oidc/userinfo";
    };
  };

  services.nginx.virtualHosts."outline.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.outline.port}";
      proxyWebsockets = true;
    };
  };

  services.restic.backups.outline = {
    paths = [
      "/var/lib/outline"
      "/tmp/postgres/outline_db.sql"
    ];
    backupPrepareCommand = ''
      install -d -m 750 -o postgres -g postgres /tmp/postgres
      ${config.security.wrapperDir}/sudo -u postgres ${pkgs.postgresql}/bin/pg_dump -F p --clean --if-exists -f /tmp/postgres/outline_db.sql outline
    '';
    backupCleanupCommand = "rm -rf /tmp/postgres";
  };
}
