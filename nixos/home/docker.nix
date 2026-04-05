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
      dockerdata = "${config.users.users.vhqkze.home}/Developer/docker";
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
      # uptime-kuma = {
      #   image = "louislam/uptime-kuma:2";
      #   ports = [ "3001:3001" ];
      #   volumes = [
      #     "/var/run/docker.sock:/var/run/docker.sock"
      #     "${dockerdata}/uptime-kuma:/app/data"
      #   ];
      # };
      # dockge = {
      #   image = "louislam/dockge:1";
      #   ports = [ "5001:5001" ];
      #   environment = {
      #     DOCKGE_STACKS_DIR = "/opt/stacks";
      #   };
      #   volumes = [
      #     "/var/run/docker.sock:/var/run/docker.sock"
      #     "${dockerdata}/dockge/data:/app/data"
      #     "${dockerdata}/dockge/stacks:/opt/stacks"
      #   ];
      # };
      # nginx-proxy-manager = {
      #   autoStart = false;
      #   image = "jc21/nginx-proxy-manager:latest";
      #   ports = [
      #     "80:80"
      #     "81:81"
      #     "443:443"
      #   ];
      #   volumes = [
      #     "${dockerdata}/nginx-proxy-manager/data:/data"
      #     "${dockerdata}/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
      #   ];
      #   extraOptions = [
      #     "--add-host=host.docker.internal:host-gateway"
      #   ];
      # };
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
      calibre = {
        image = "lscr.io/linuxserver/calibre-web:latest";
        ports = [ "8083:8083" ];
        environment = {
          TZ = config.time.timeZone;
          PUID = uid;
          PGID = gid;
          DOCKER_MODS = "linuxserver/mods:universal-calibre";
        };
        volumes = [
          "${dockerdata}/calibre/config:/config"
          "${dockerdata}/calibre/books:/books"
        ];
      };
      # calibre-web-automated = {
      #   image = "crocodilestick/calibre-web-automated:latest";
      #   ports = [ "8083:8083" ];
      #   environment = {
      #     TZ = config.time.timeZone;
      #     PUID = "1000";
      #     PGID = toString config.users.groups.${config.users.users.vhqkze.group}.gid;
      #     HARDCOVER_TOKEN = "";
      #     NETWORK_SHARE_MODE = "false";
      #     CWA_PORT_OVERRIDE = "8083";
      #   };
      #   volumes = [
      #     "${config.users.users.vhqkze.home}/Developer/docker/calibre/config:/config"
      #     "${config.users.users.vhqkze.home}/Developer/docker/calibre/config:/calibre-library"
      #     "${config.users.users.vhqkze.home}/Developer/docker/calibre/config:/config/.config/calibre/plugins"
      #     "${config.users.users.vhqkze.home}/Developer/docker/calibre/books:/cwa-book-ingest"
      #   ];
      # };
      # jupyterlab = {
      #   image = "quay.io/jupyter/minimal-notebook:latest";
      #   ports = [ "8000:8888" ];
      #   environment = {
      #     CHOWN_HOME = "yes";
      #     NB_UID = "1000";
      #     NB_GID = "100";
      #   };
      #   volumes = [
      #     "${config.users.users.vhqkze.home}/Developer/docker/jupyterlab:/home/jovyan/notebook"
      #   ];
      #   cmd = [
      #     "start-notebook.py"
      #     "--ServerApp.root_dir=/home/jovyan/notebook"
      #     "--PasswordIdentityProvider.hashed_password='argon2:$argon2id$v=19$m=10240,t=10,p=8$A8DmIgXL7PaJDVpR3lTHtA$EKKljGoJpXZfZpyMQc9H8DRMNZDWBxoZCBMtnskB5uM'"
      #   ];
      # };
      # netdata = {
      #   autoStart = false;
      #   image = "netdata/netdata:latest";
      #   volumes = [
      #     "${dockerdata}/netdata/netdataconfig:/etc/netdata"
      #     "${dockerdata}/netdata/netdatalib:/var/lib/netdata"
      #     "${dockerdata}/netdata/netdatacache:/var/cache/netdata"
      #     "/:/host/root:ro,rslave"
      #     "/etc/passwd:/host/etc/passwd:ro"
      #     "/etc/group:/host/etc/group:ro"
      #     "/etc/localtime:/etc/localtime:ro"
      #     "/proc:/host/proc:ro"
      #     "/sys:/host/sys:ro"
      #     "/etc/os-release:/host/etc/os-release:ro"
      #     "/var/log:/host/var/log:ro"
      #     "/var/run/docker.sock:/var/run/docker.sock:ro"
      #     "/run/dbus:/run/dbus:ro"
      #   ];
      #   extraOptions = [
      #     "--pid=host"
      #     "--network=host"
      #     "--security-opt"
      #     "apparmor=unconfined"
      #   ];
      #   capabilities = {
      #     SYS_ADMIN = true;
      #     SYS_PTRACE = true;
      #   };
      # };
      beszel-agent = {
        image = "henrygd/beszel-agent";
        environment = {
          LISTEN = "/beszel_socket/beszel.sock";
          HUB_URL = "http://localhost:8090";
        };
        environmentFiles = [ config.sops.secrets."docker/beszel_agent".path ];
        volumes = [
          "${dockerdata}/beszel/agent_data:/var/lib/beszel-agent"
          "${dockerdata}/beszel/beszel_socket:/beszel_socket"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      beszel-hub = {
        image = "henrygd/beszel";
        ports = [ "8090:8090" ];
        volumes = [
          "${dockerdata}/beszel/hub_data:/beszel_data"
          "${dockerdata}/beszel/beszel_socket:/beszel_socket"
        ];
      };
      scrutiny = {
        image = "ghcr.io/analogj/scrutiny:master-omnibus";
        ports = [
          "8085:8080"
          "8086:8086"
        ];
        volumes = [
          "${dockerdata}/scrutiny/config:/opt/scrutiny/config"
          "${dockerdata}/scrutiny/influxdb2:/opt/scrutiny/influxdb"
          "/run/udev:/run/udev:ro"
        ];
        capabilities = {
          SYS_RAWIO = true;
          SYS_ADMIN = true;
        };
        devices = [
          "/dev/sda"
          "/dev/sdb"
        ];
      };
      tugtainer = {
        image = "quenary/tugtainer:latest";
        ports = [ "9412:80" ];
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
