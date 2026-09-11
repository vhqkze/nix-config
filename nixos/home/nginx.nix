{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    {
      options.services.nginx.virtualHosts = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            config = {
              forceSSL = lib.mkDefault true;
              sslCertificate = lib.mkDefault config.sops.secrets."nginx/home.pem".path;
              sslCertificateKey = lib.mkDefault config.sops.secrets."nginx/home-key.pem".path;
            };
          }
        );
      };
    }
  ];

  services.nginx = {
    enable = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedUwsgiSettings = true;
    virtualHosts = {
      "_" = {
        default = true;
        globalRedirect = "home";
      };
      "wifi.home" = {
        locations."/".proxyPass = "http://tplogin.cn";
      };
      "clash.home" = {
        locations."/" = {
          proxyPass = "http://router.local:9090";
          proxyWebsockets = true;
        };
      };
      "adguard.home" = {
        locations."/".proxyPass = "http://router.local:3000";
      };
    };
  };
}
