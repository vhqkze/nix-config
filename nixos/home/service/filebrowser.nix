{
  config,
  pkgs,
  ...
}:
let
  version = "1.4.2-beta";
  downloadedApp = pkgs.fetchurl {
    url = "https://github.com/gtsteffaniak/filebrowser/releases/download/v${version}/linux-amd64-filebrowser";
    hash = "sha256-DXVz1Syn+vpT6dSCydM19Xlfvm/k2EQxhpKt3+00DyY=";
  };

  filebrowserExecutable = pkgs.runCommand "filebrowser-wrapper" { } ''
    install -D -m555 ${downloadedApp} $out/bin/filebrowser-quantum
  '';

  fbConfig = pkgs.writeText "filebrowser-config.yaml" ''
    server:
      listen: "localhost"
      port: 8084
      # database: "/var/lib/filebrowser-quantum/database.db"
      # cacheDir: "/var/cache/filebrowser-quantum/tmp"
      database: "database.db"
      cacheDir: "tmp"
      sources:
        - path: "${config.users.users.vhqkze.home}"
          name: Home
          config:
            defaultEnabled: true
        - path: "/mnt/disk"
          config:
            defaultEnabled: true

    http:
      trustedHeaders:
        - X-Forwarded-For
        - X-Real-IP

    auth:
      adminUsername: vhqkze
      methods:
        password:
          enabled: true
          minLength: 5
          signup: false

    frontend:
      disableDefaultLinks: true

    integrations:
      media:
        ffmpegPath: "${pkgs.ffmpeg}/bin"

    userDefaults:
      fileViewer:
        defaultMediaPlayer: true
      preview:
        folder: false
      listing:
        dateFormat: true
        quickDownload: true
        deleteAfterArchive: false
  '';

  # startScript = pkgs.writeShellScript "start-filebrowser" ''
  #   exec ${filebrowserExecutable}/bin/filebrowser-quantum -c "${fbConfig}"
  # '';
in
{

  systemd.services.filebrowser = {
    description = "FileBrowser Quantum Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/var/lib/filebrowser-quantum";
      StateDirectory = "filebrowser-quantum";
      CacheDirectory = "filebrowser-quantum";
      EnvironmentFile = config.sops.secrets."service/filebrowser".path;

      Type = "simple";
      User = "vhqkze";

      # ExecStart = "${startScript}";
      ExecStart = "${filebrowserExecutable}/bin/filebrowser-quantum -c ${fbConfig}";

      Restart = "always";
      RestartSec = "10s";

      ProtectSystem = "full";
      DeviceAllow = "";
      NoNewPrivileges = true;
    };
  };
}
