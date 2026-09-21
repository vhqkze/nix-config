{
  config,
  pkgs,
  ...
}:
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "grimmory" ];
    ensureUsers = [
      {
        name = "grimmory";
        ensurePermissions = {
          "grimmory.*" = "ALL PRIVILEGES";
        };
      }
    ];
    settings = {
      mysqld = {
        bind-address = "127.0.0.1,172.17.0.1";
        port = 3306;
        character-set-server = "utf8mb4";
        collation-server = "utf8mb4_unicode_ci";
        max_connections = 100;
        innodb_buffer_pool_size = "512M";
        key_buffer_size = "16M";
        max_allowed_packet = "32M";
        table_open_cache = 400;
        sort_buffer_size = "512K";
        read_buffer_size = "256K";
        read_rnd_buffer_size = "512K";
        join_buffer_size = "256K";
      };
      client = {
        default-character-set = "utf8mb4";
      };
      mysql = {
        default-character-set = "utf8mb4";
      };
    };
  };
}
