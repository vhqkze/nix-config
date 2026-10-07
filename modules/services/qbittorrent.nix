{
  config,
  ...
}:
{
  services.qbittorrent = {
    enable = true;
    webuiPort = 9680;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Address = "127.0.0.1";
          Username = "qbittorrent";
          # nix run git+https://codeberg.org/feathecutie/qbittorrent_password -- -p [password here]
          Password_PBKDF2 = "@ByteArray(ZbQeGFOKf8nl/WQUeAnoBQ==:SdmsVNiS4rAtaA09EpIsRupaZoeZkgZ5mR1qorPOorRBFNmGfgbhWJkuYrb/wKBuPwyEFtZuNQ2z0pLBT1dpjA==)";
          AlternativeUIEnabled = false;
        };
        Downloads = {
          SavePath = "${config.services.qbittorrent.profileDir}/Downloads";
          TempPath = "${config.services.qbittorrent.profileDir}/incomplete";
          TempPathEnabled = true;
        };
        General = {
          Locale = "zh_CN";
          StatusbarExternalIPDisplayed = true;
        };
      };
      BitTorrent = {
        MergeTrackersEnabled = true;
        Session = {
          GlobalMaxRatio = "1";
          GlobalMaxSeedingMinutes = 0;
          MaxActiveDownloads = 10;
          MaxActiveTorrents = 15;
          MaxActiveUploads = 10;
          QueueingSystemEnabled = true;
        };
      };
      Core = {
        AutoDeleteAddedTorrentFile = "IfAdded";
      };
    };
  };

  services.nginx.virtualHosts."qbt.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.qbittorrent.webuiPort}";
    };
  };

  sops.secrets.qui.owner = config.services.qui.user;
  sops.secrets.qui-env.owner = config.services.qui.user;

  services.qui = {
    enable = config.services.qbittorrent.enable;
    secretFile = config.sops.secrets.qui.path;
    settings = {
      host = "127.0.0.1";
      port = 9681;
      sessionCookieSecure = true;
      checkForUpdates = false;
      oidcEnabled = true;
      oidcIssuer = "https://pocket-id.home";
      oidcClientId = "qui";
      oidcRedirectUrl = "https://bt.home/api/auth/oidc/callback";
      oidcDisableBuiltInLogin = true;
    };
  };

  systemd.services.qui.serviceConfig.EnvironmentFile = config.sops.secrets.qui-env.path;

  services.nginx.virtualHosts."bt.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.qui.settings.port}";
    };
  };
}
