{
  config,
  ...
}:
{
  services.webdav = {
    enable = true;
    environmentFile = config.sops.secrets."webdav".path;
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
}
