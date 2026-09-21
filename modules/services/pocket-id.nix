{
  config,
  ...
}:
{
  services.pocket-id = {
    enable = true;
    environmentFile = config.sops.secrets."service/pocket-id".path;
    settings = {
      APP_URL = "https://pocket-id.home";
      TRUST_PROXY = true;
      ANALYTICS_DISABLED = false;
      ALLOW_INSECURE_CALLBACK_URLS = true;
      PORT = 1411;
      HOST = "127.0.0.1";
      UI_CONFIG_DISABLED = true;
    };
  };

  # 初次部署后，打开 https://<your-app-url>/setup 注册管理员账号

  services.nginx.virtualHosts."pocket-id.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.pocket-id.settings.PORT}";
    };
    extraConfig = ''
      proxy_busy_buffers_size 512k;
      proxy_buffers 4 512k;
      proxy_buffer_size 256k;
    '';
  };

  services.restic.backups.pocket-id = {
    paths = [ config.services.pocket-id.dataDir ];
    backupPrepareCommand = "systemctl stop pocket-id.service";
    backupCleanupCommand = "systemctl start pocket-id.service";
  };
}
