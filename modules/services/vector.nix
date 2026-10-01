{
  config,
  ...
}:
{
  services.vector = {
    enable = true;
    journaldAccess = true;
    validateConfig = true;
    settings = {
      sources = {
        journald_logs = {
          type = "journald";
          current_boot_only = true;
          exclude_units = [ "vector" ];
        };
      };
      transforms = {
        enrich_journald = {
          type = "remap";
          inputs = [ "journald_logs" ];
          source = ''
            .service_name = string(.UNIT) ?? string(._SYSTEMD_UNIT) ?? string(._SYSTEMD_USER_UNIT) ?? string(.SYSLOG_IDENTIFIER) ?? "unknown_service"
          '';
        };
      };
      sinks = {
        loki_sink = {
          type = "loki";
          inputs = [ "enrich_journald" ];
          endpoint =
            if config.services.loki.enable then
              "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}"
            else
              "https://loki.home";
          encoding.codec = "json";
          labels = {
            source = "journald";
            host = config.networking.hostName;
            service_name = "{{ .service_name }}";
          };
        };
      };
    };
  };
}
