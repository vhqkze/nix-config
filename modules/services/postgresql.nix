{
  config,
  pkgs,
  ...
}:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;
    settings = {
      port = 5432;
      listen_addresses = "*";
    };
  };
}
