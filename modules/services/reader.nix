{
  config,
  dockerDir,
  ...
}:
{
  virtualisation.oci-containers.containers.reader = {
    image = "hectorqin/reader";
    ports = [ "8080:8080" ];
    environment = {
      SPRING_PROFILES_ACTIVE = "prod";
    };
    volumes = [
      "${dockerDir}/reader/storage:/storage"
      "${dockerDir}/reader/logs:/logs"
    ];
  };

  services.nginx.virtualHosts."reader.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
      proxyWebsockets = true;
    };
    basicAuthFile = config.sops.secrets."nginx/reader".path;
  };
}
