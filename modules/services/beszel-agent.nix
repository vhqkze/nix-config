{
  config,
  ...
}:
{
  sops.secrets.beszel-agent = { };

  services.beszel.agent = {
    enable = true;
    environment.LISTEN = "45876";
    environmentFile = config.sops.secrets.beszel-agent.path;
    smartmon = {
      enable = true;
    };
  };
}
