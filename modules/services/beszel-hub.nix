{
  config,
  ...
}:
{
  sops.secrets.beszel-hub = { };

  services.beszel.hub = {
    enable = true;
    port = 8090;
    environmentFile = config.sops.secrets.beszel-hub.path;
  };

  services.nginx.virtualHosts."beszel.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.beszel.hub.port}";
    };
  };
}
