{
  config,
  dockerDir,
  ...
}:
{
  virtualisation.oci-containers.containers.homepage =
    let
      uid = "1000";
      # uid = toString config.users.users.vhqkze.uid; # 不能用这个，这个值是空的
      gid = toString config.users.groups.${config.users.users.vhqkze.group}.gid;
    in
    {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = [ "3300:3000" ];
      environment = {
        HOMEPAGE_ALLOWED_HOSTS = "*";
        PUID = uid;
        PGID = gid;
      };
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "${dockerDir}/homepage/config:/app/config"
        "${dockerDir}/homepage/icons:/app/public/icons"
        "${dockerDir}/homepage/images:/app/public/images"
      ];
    };

  services.nginx.virtualHosts."home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:3300";
    };
  };

  services.restic.backups.homepage = {
    paths = [ "${dockerDir}/homepage" ];
  };
}
