{
  config,
  pkgs,
  inputs,
  ...
}:
{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers =
    let
      dockerdata = "/srv/docker";
      uid = "1000";
      # uid = toString config.users.users.vhqkze.uid; # 不能用这个，这个值是空的
      gid = toString config.users.groups.${config.users.users.vhqkze.group}.gid;
    in
    {
      homepage = {
        image = "ghcr.io/gethomepage/homepage:latest";
        ports = [ "3300:3000" ];
        environment = {
          HOMEPAGE_ALLOWED_HOSTS = "*";
          PUID = uid;
          PGID = gid;
        };
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "${dockerdata}/homepage/config:/app/config"
          "${dockerdata}/homepage/icons:/app/public/icons"
          "${dockerdata}/homepage/images:/app/public/images"
        ];
      };
      linkding = {
        image = "ghcr.io/sissbruecker/linkding:latest";
        ports = [ "9090:9090" ];
        volumes = [
          "${dockerdata}/linkding:/etc/linkding/data"
        ];
      };
      memos = {
        image = "neosmemo/memos:stable";
        ports = [ "5230:5230" ];
        volumes = [
          "${dockerdata}/memos/:/var/opt/memos"
        ];
      };
      plex = {
        image = "plexinc/pms-docker";
        environment = {
          TZ = config.time.timeZone;
        };
        environmentFiles = [ config.sops.secrets."docker/plex".path ];
        volumes = [
          "${dockerdata}/plex/config:/config"
          "${dockerdata}/plex/transcode:/transcode"
          "/mnt/disk/movies:/data/movies"
          "/mnt/disk/tvshows:/data/tvshows"
        ];
        extraOptions = [ "--network=host" ];
      };
      reader = {
        image = "hectorqin/reader";
        ports = [ "8080:8080" ];
        environment = {
          SPRING_PROFILES_ACTIVE = "prod";
        };
        volumes = [
          "${dockerdata}/reader/storage:/storage"
          "${dockerdata}/reader/logs:/logs"
        ];
      };
      kavita = {
        image = "ghcr.io/kareadita/kavita:latest";
        ports = [ "5000:5000" ];
        environment = {
          TZ = config.time.timeZone;
        };
        volumes = [
          "${dockerdata}/kavita/manga:/manga"
          "${dockerdata}/kavita/comics:/comics"
          "${dockerdata}/kavita/books:/books"
          "${dockerdata}/kavita/config:/kavita/config"
        ];
      };
      grimmory_db = {
        image = "mariadb:latest";
        ports = [ "3306:3306" ];
        environment = {
          TZ = config.time.timeZone;
          MYSQL_DATABASE = "grimmory";
          MYSQL_USER = "grimmory";
        };
        environmentFiles = [ config.sops.secrets."docker/grimmory_db".path ];
        volumes = [
          "${dockerdata}/grimmory_db:/var/lib/mysql"
        ];
      };
      grimmory = {
        image = "ghcr.io/grimmory-tools/grimmory:latest";
        ports = [ "6060:6060" ];
        dependsOn = [ "grimmory_db" ];
        environment = {
          USER_ID = uid;
          GROUP_ID = gid;
          TZ = config.time.timeZone;
          DATABASE_URL = "jdbc:mariadb://host.docker.internal:3306/grimmory";
          DATABASE_USERNAME = "grimmory";
          API_DOCS_ENABLED = "false";
        };
        environmentFiles = [ config.sops.secrets."docker/grimmory".path ];
        volumes = [
          "${dockerdata}/grimmory/data:/app/data"
          "${dockerdata}/grimmory/library:/library"
          "${dockerdata}/grimmory/bookdrop:/bookdrop"
        ];
        extraOptions = [
          "--add-host=host.docker.internal:host-gateway"
        ];
      };
      tugtainer = {
        image = "quenary/tugtainer:latest";
        ports = [ "9412:80" ];
        environmentFiles = [ config.sops.secrets."docker/tugtainer".path ];
        volumes = [
          "${dockerdata}/tugtainer:/tugtainer"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
      };
      ezbookkeeping = {
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
          "${dockerdata}/ezbookkeeping/data:/ezbookkeeping/data"
          "${dockerdata}/ezbookkeeping/storage:/ezbookkeeping/storage"
          "${dockerdata}/ezbookkeeping/log:/ezbookkeeping/log"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
      };
    };
}
