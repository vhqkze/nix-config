{
  config,
  ...
}:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
  };
  services.nginx.virtualHosts =
    let
      base = locations: {
        inherit locations;
        addSSL = true;
        sslCertificate = config.sops.secrets."nginx/ssl_cert".path;
        sslCertificateKey = config.sops.secrets."nginx/ssl_key".path;

        # forceSSL = true;
      };
      proxy =
        port:
        base {
          "/".proxyPass = "http://127.0.0.1:" + toString port + "/";
        };
      proxyWithWs =
        port:
        base {
          "/".proxyPass = "http://127.0.0.1:" + toString port + "/";
          "/".proxyWebsockets = true;
        };
      proxyRemote =
        url:
        base {
          "/".proxyPass = url;
        };
    in
    {
      "home" = proxy 3300;
      "actual.home" = proxy 5006;
      "beszel.home" = proxy 8090;
      "book.home" = proxyWithWs 6060;
      "booklore.home" = proxyWithWs 6061;
      "calibre.home" = proxy 8083;
      "dev.home" = proxy 6610;
      "dockge.home" = proxy 5001;
      "docker.home" = proxy 9412;
      "file.home" = proxy 8084;
      "gitness.home" = proxy 3010;
      "grafana.home" = proxy 3000;
      "hoppscotch.home" = proxy 3101;
      "jupyterlab.home" = proxy 8000;
      "kavita.home" = proxy 5000;
      "link.home" = proxy 9090;
      "memos.home" = proxy 5230;
      "netdata.home" = proxy 19999;
      "nginx.home" = proxy 81;
      "pdf.home" = proxy 20608;
      "plex.home" = proxy 32400;
      "portainer.home" = proxy 9443;
      "reader.home" = proxy 8080 // {
        basicAuthFile = config.sops.secrets."nginx/reader".path;
      };
      "scrutiny.home" = proxy 8085;
      "wifi.home" = proxyRemote "http://tplogin.cn/";
      "clash.home" = proxyRemote "http://openwrt:9090/ui/dashboard/"; # 307
      "xiaoya.home" = proxy 5678;
      "status.home" = proxy 7020;
      "money.home" = proxy 7080;
      "adguard.home" = proxyRemote "http://openwrt:3000/";
      "router.home" = proxyRemote "http://openwrt/";

      "webdav.home" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9080/";
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
        addSSL = true;
        sslCertificate = config.sops.secrets."nginx/ssl_cert".path;
        sslCertificateKey = config.sops.secrets."nginx/ssl_key".path;
      };
    };
}
