{
  config,
  ...
}:
{
  services.beszel.hub = {
    enable = true;
    port = 8090;
    environmentFile = config.sops.secrets."service/beszel_hub".path;
  };

  services.beszel.agent = {
    enable = true;
    environment.LISTEN = "45876";
    environmentFile = config.sops.secrets."service/beszel_agent".path;
    smartmon = {
      enable = true;
    };
  };
}
