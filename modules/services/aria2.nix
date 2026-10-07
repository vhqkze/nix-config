{
  config,
  pkgs,
  ...
}:
{
  sops.secrets.aria2 = { };

  services.aria2 = {
    enable = true;
    openPorts = true;
    serviceUMask = "0002";
    downloadDirPermission = "0777";
    rpcSecretFile = config.sops.secrets.aria2.path;
    settings = {
      dir = "/var/lib/aria2/Downloads";
      rpc-allow-origin-all = true;
      rpc-listen-all = true;
      max-concurrent-downloads = 10;
      continue = true;
      max-connection-per-server = 12;
      min-split-size = "10M";
      split = 16;
      auto-file-renaming = true;
      bt-save-metadata = true;
      file-allocation = "falloc";
      save-session-interval = 60;
      bt-require-crypto = true;
      seed-time = 0;
    };
  };

  services.nginx.virtualHosts."ariang.home" = {
    root = "${pkgs.ariang}/share/ariang";
    locations."/".index = "index.html";
    locations."/jsonrpc" = {
      proxyPass = "http://127.0.0.1:6800/jsonrpc";
      proxyWebsockets = true;
    };
  };
}
