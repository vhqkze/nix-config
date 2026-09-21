{
  config,
  dockerDir,
  ...
}:
{
  virtualisation.oci-containers.containers.kavita = {
    image = "ghcr.io/kareadita/kavita:latest";
    ports = [ "5000:5000" ];
    environment = {
      TZ = config.time.timeZone;
    };
    volumes = [
      "${dockerDir}/kavita/manga:/manga"
      "${dockerDir}/kavita/comics:/comics"
      "${dockerDir}/kavita/books:/books"
      "${dockerDir}/kavita/config:/kavita/config"
    ];
  };

  services.nginx.virtualHosts."kavita.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      proxyWebsockets = true;
    };
  };
}
