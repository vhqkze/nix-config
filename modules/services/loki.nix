{
  config,
  ...
}:
{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3100;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = 9095;
      };
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring = {
          kvstore.store = "inmemory";
        };
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
      };
      schema_config.configs = [
        {
          from = "2026-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
    };
  };

  services.nginx.virtualHosts."loki.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
      proxyWebsockets = true;
    };
    locations."/grpc/" = {
      extraConfig = ''
        grpc_pass grpc://127.0.0.1:${toString config.services.loki.configuration.server.grpc_listen_port};
        grpc_read_timeout 600s;
        grpc_send_timeout 600s;
      '';
    };
  };
}
