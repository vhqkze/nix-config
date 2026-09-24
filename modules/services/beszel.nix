{
  config,
  ...
}:
{
  sops.secrets.beszel_hub = { };
  sops.secrets.beszel_agent = { };

  services.beszel.hub = {
    enable = true;
    port = 8090;
    environmentFile = config.sops.secrets.beszel_hub.path;
  };

  services.beszel.agent = {
    enable = true;
    environment.LISTEN = "45876";
    environmentFile = config.sops.secrets.beszel_agent.path;
    smartmon = {
      enable = true;
    };
  };

  services.nginx.virtualHosts."beszel.home" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.beszel.hub.port}";
    };
  };
}
