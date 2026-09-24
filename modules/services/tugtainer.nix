{
  config,
  dockerDir,
  ...
}:
{
  sops.secrets.tugtainer = { };

  virtualisation.oci-containers.containers.tugtainer = {
    image = "quenary/tugtainer:latest";
    ports = [ "9412:80" ];
    environmentFiles = [ config.sops.secrets.tugtainer.path ];
    volumes = [
      "${dockerDir}/tugtainer:/tugtainer"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
  };

  services.nginx.virtualHosts."docker.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:9412";
    };
  };
}
