{
  config,
  pkgs,
  ...
}:
let
  fbConfig = pkgs.writers.writeYAML "filebrowser-config.yaml" {
    server = {
      listen = "localhost";
      port = 8084;
      database = "database.db";
      cacheDir = "tmp";
      sources = [
        {
          path = config.users.users.vhqkze.home;
          name = "Home";
          config.defaultEnabled = true;
        }
        {
          path = "/mnt/disk";
          config.defaultEnabled = true;
        }
      ];
    };
    http.trustedHeaders = [
      "X-Forwarded-For"
      "X-Real-IP"
    ];
    auth = {
      adminUsername = config.users.users.vhqkze.name;
      methods.password = {
        enabled = true;
        minLength = 5;
        signup = false;
      };
    };
    frontend.disableDefaultLinks = true;
    integrations.media.ffmpegPath = "${pkgs.ffmpeg}/bin";
    userDefaults = {
      fileViewer.defaultMediaPlayer = true;
      preview.folder = false;
      listing = {
        dateFormat = true;
        quickDownload = true;
        deleteAfterArchive = false;
      };
    };
  };
in
{
  sops.secrets.filebrowser = { };

  systemd.services.filebrowser = {
    description = "FileBrowser Quantum Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/var/lib/filebrowser-quantum";
      StateDirectory = "filebrowser-quantum";
      CacheDirectory = "filebrowser-quantum";
      EnvironmentFile = config.sops.secrets.filebrowser.path;

      Type = "simple";
      User = "vhqkze";

      ExecStart = "${pkgs.unstable.filebrowser-quantum}/bin/filebrowser-quantum -c ${fbConfig}";

      Restart = "always";
      RestartSec = "10s";

      ProtectSystem = "full";
      DeviceAllow = "";
      NoNewPrivileges = true;
    };
  };

  services.nginx.virtualHosts."file.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8084";
    };
    extraConfig = ''
      client_max_body_size 10G;
    '';
  };
}
