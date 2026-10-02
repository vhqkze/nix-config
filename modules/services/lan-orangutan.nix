{
  config,
  dockerDir,
  ...
}:
{
  sops.secrets.lan-orangutan = { };

  virtualisation.oci-containers.containers.lan-orangutan = {
    image = "ghcr.io/291-group/lan-orangutan:3.3.8";
    capabilities = {
      NET_RAW = true;
      NET_ADMIN = true;
      NET_BIND_SERVICE = true;
    };
    extraOptions = [ "--network=host" ];
    environment = {
      TZ = config.time.timeZone;
      ORANGUTAN_PORT = "9800";
    };
    environmentFiles = [ config.sops.secrets.lan-orangutan.path ];
    volumes = [
      "${dockerDir}/lan-orangutan:/var/lib/lan-orangutan"
    ];
  };

  services.nginx.virtualHosts."lan.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:9800";
    };
  };
}
