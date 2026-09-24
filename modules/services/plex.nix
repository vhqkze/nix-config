{
  config,
  dockerDir,
  ...
}:
{
  sops.secrets.plex = { };

  virtualisation.oci-containers.containers.plex = {
    image = "plexinc/pms-docker";
    environment = {
      TZ = config.time.timeZone;
    };
    environmentFiles = [ config.sops.secrets.plex.path ];
    volumes = [
      "${dockerDir}/plex/config:/config"
      "${dockerDir}/plex/transcode:/transcode"
      "/mnt/disk/movies:/data/movies"
      "/mnt/disk/tvshows:/data/tvshows"
    ];
    extraOptions = [ "--network=host" ];
  };

  services.nginx.virtualHosts."plex.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:32400";
      proxyWebsockets = true;
    };
  };

  services.restic.backups.plex = {
    paths = [ "${dockerDir}/plex" ];
  };

  networking.firewall.allowedTCPPorts = [ 32400 ];
}
