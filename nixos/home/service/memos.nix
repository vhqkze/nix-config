{
  config,
  pkgs,
  ...
}:
{
  services.memos = {
    enable = true;
    package = pkgs.unstable.memos;
    settings = {
      MEMOS_MODE = "prod";
      MEMOS_ADDR = "127.0.0.1";
      MEMOS_PORT = "5230";
      MEMOS_DATA = config.services.memos.dataDir;
      MEMOS_DRIVER = "sqlite";
      MEMOS_INSTANCE_URL = "https://memos.home";
    };
  };
}
