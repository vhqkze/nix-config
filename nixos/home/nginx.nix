{
  config,
  ...
}:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "100m";
    virtualHosts =
      let
        base = {
          addSSL = true;
          sslCertificate = config.sops.secrets."nginx/home.pem".path;
          sslCertificateKey = config.sops.secrets."nginx/home-key.pem".path;
        };
        proxy =
          port: extra:
          let
            isPort = builtins.isInt port || (builtins.isString port && builtins.match "[0-9]+" port != null);
            proxyUrl = if isPort then "http://127.0.0.1:${toString port}" else port;
          in
          (
            base
            // {
              locations."/" = {
                proxyPass = proxyUrl;
              }
              // (extra.locationExtra or { });
            }
            // (removeAttrs extra [ "locationExtra" ])
          );
      in
      {
        "_" = base // {
          default = true;
          globalRedirect = "home";
        };
        "home" = proxy 3300 { };
        "beszel.home" = proxy config.services.beszel.hub.port { };
        "book.home" = proxy 6060 {
          locationExtra = {
            proxyWebsockets = true;
          };
          extraConfig = ''
            client_max_body_size 10G;
          '';
        };
        "calibre.home" = proxy 8083 { };
        "docker.home" = proxy 9412 { };
        "file.home" = proxy 8084 {
          extraConfig = ''
            client_max_body_size 10G;
          '';
        };
        "git.home" = proxy "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}" { };
        "kavita.home" = proxy 5000 {
          locationExtra = {
            proxyWebsockets = true;
          };
        };
        "link.home" = proxy config.services.linkding.port { };
        "memos.home" = proxy config.services.memos.settings.MEMOS_PORT { };
        "outline.home" = proxy config.services.outline.port {
          locationExtra = {
            proxyWebsockets = true;
          };
        };
        "plex.home" = proxy 32400 {
          locationExtra = {
            proxyWebsockets = true;
          };
        };
        "reader.home" = proxy 8080 {
          basicAuthFile = config.sops.secrets."nginx/reader".path;
        };
        "wifi.home" = proxy "http://tplogin.cn" { };
        "clash.home" = proxy "http://router.local:9090" {
          locationExtra = {
            proxyWebsockets = true;
          };
        };
        "status.home" = proxy config.services.gatus.settings.web.port { };
        "money.home" = proxy 7080 { };
        "adguard.home" = proxy "http://router.local:3000" { };
        "readeck.home" = proxy config.services.readeck.settings.server.port { };
        "pocket-id.home" = proxy config.services.pocket-id.settings.PORT {
          extraConfig = ''
            proxy_busy_buffers_size 512k;
            proxy_buffers 4 512k;
            proxy_buffer_size 256k;
          '';
        };

        "webdav.home" = proxy 9080 {
          extraConfig = ''
            # WebDAV specific settings not covered by recommendedProxySettings
            proxy_request_buffering off;
            client_max_body_size 0;

            # WebDAV method headers
            proxy_set_header Depth $http_depth;
            proxy_set_header Destination $http_destination;
            proxy_set_header Overwrite $http_overwrite;
            proxy_set_header Translate $http_translate;
          '';
        };
      };
  };
}
