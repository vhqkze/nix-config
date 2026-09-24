{
  config,
  ...
}:
{
  sops.secrets.webdav = { };

  services.webdav = {
    enable = true;
    environmentFile = config.sops.secrets.webdav.path;
    settings = {
      address = "0.0.0.0";
      port = 9080;
      user = "vhqkze";
      behindProxy = true;
      directory = "/mnt/disk";
      permissions = "CRUD"; # Create, Read, Update, Delete permissions
      users = [
        {
          username = "{env}WEBDAV_USERNAME";
          password = "{env}WEBDAV_PASSWORD";
        }
      ];
    };
  };

  services.nginx.virtualHosts."webdav.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.webdav.settings.port}";
    };
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
}
