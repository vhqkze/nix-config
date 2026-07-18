{
  config,
  pkgs,
  ...
}:
{
  services.linkding = {
    enable = true;
    package = pkgs.linkding;
    port = 9090;
    environmentFile = config.sops.secrets."service/linkding".path;
    settings = {
      LD_DISABLE_BACKGROUND_TASKS = "True";
      LD_DISABLE_URL_VALIDATION = "True";
    };
  };
}
