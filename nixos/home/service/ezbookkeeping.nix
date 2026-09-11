{
  config,
  dockerDir,
  ...
}:
{
  virtualisation.oci-containers.containers.ezbookkeeping = {
    image = "mayswind/ezbookkeeping:latest";
    ports = [ "7080:8080" ];
    environment = {
      EBK_USER_ENABLE_REGISTER = "true";
      EBK_SECURITY_ENABLE_API_TOKEN = "true";
      EBK_SERVER_DOMAIN = "money.home";
      EBK_SERVER_ROOT_URL = "https://money.home/";
    };
    environmentFiles = [ config.sops.secrets."docker/ezbookkeeping".path ];
    volumes = [
      "${dockerDir}/ezbookkeeping/data:/ezbookkeeping/data"
      "${dockerDir}/ezbookkeeping/storage:/ezbookkeeping/storage"
      "${dockerDir}/ezbookkeeping/log:/ezbookkeeping/log"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
  };

  services.nginx.virtualHosts."money.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:7080";
    };
  };

  services.restic.backups.ezbookkeeping = {
    paths = [ "${dockerDir}/ezbookkeeping" ];
  };
}
