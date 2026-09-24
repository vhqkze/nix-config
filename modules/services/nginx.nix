{
  config,
  pkgs,
  lib,
  inputs ? null,
  ...
}:
let
  # 证书存放路径
  certDir = "/var/lib/nginx-certs";
  certFile = "${certDir}/home.pem";
  keyFile = "${certDir}/home-key.pem";

  # 基础固定通配符和本地地址
  baseDomains = [
    "*.home"
    "localhost"
    "127.0.0.1"
    "::1"
  ];

  # 从 inputs.self.nixosConfigurations 读取所有主机的 virtualHosts
  autoCollectedDomains =
    if inputs != null && inputs ? self && inputs.self ? nixosConfigurations then
      lib.concatLists (
        lib.mapAttrsToList (
          _hostName: hostCfg:
          lib.flatten (
            lib.mapAttrsToList (name: vhost: [ name ] ++ (vhost.serverAliases or [ ])) (
              hostCfg.config.services.nginx.virtualHosts or { }
            )
          )
        ) inputs.self.nixosConfigurations
      )
    else
      # 兜底：如果拿不到 inputs.self，仅收集当前这台机器
      lib.flatten (
        lib.mapAttrsToList (name: vhost: [ name ] ++ (vhost.serverAliases or [ ])) (
          config.services.nginx.virtualHosts or { }
        )
      );

  # 合并、排序、去重（排序确保数组元素顺序稳定，避免因无序导致的不必要重新生成）
  allDomains = lib.naturalSort (
    # 过滤掉 "_" 以及空字符串等无效域名
    lib.unique (lib.filter (d: d != "_" && d != "") (baseDomains ++ autoCollectedDomains))
  );
  domainsArg = lib.escapeShellArgs allDomains;
in
{
  systemd.tmpfiles.rules = [
    "d ${certDir} 0700 nginx nginx -"
  ];

  sops.secrets."mkcert/rootCA.pem" = {
    format = "binary";
    sopsFile = "${inputs.self}/secrets/common/mkcert-ca.pem.asc";
    mode = "0400";
  };
  sops.secrets."mkcert/rootCA-key.pem" = {
    format = "binary";
    sopsFile = "${inputs.self}/secrets/common/mkcert-key.pem.asc";
    mode = "0400";
    reloadUnits = [ "generate-mkcert-nginx.service" ];
  };

  systemd.services.generate-mkcert-nginx = {
    description = "Generate mkcert wildcard certificates for Nginx";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];
    path = [ pkgs.mkcert ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    environment = {
      CAROOT = dirOf config.sops.secrets."mkcert/rootCA.pem".path;
    };
    script = ''
      set -euo pipefail
      echo "Generating mkcert certificates for: ${toString allDomains}"
      # 写入临时文件，然后原子替换，避免 nginx 读到中途写入的半成品文件
      mkcert -cert-file "${certFile}.tmp" -key-file "${keyFile}.tmp" ${domainsArg}
      mv -f "${certFile}.tmp" "${certFile}"
      mv -f "${keyFile}.tmp" "${keyFile}"
      # 修正文件所有者和权限
      chown nginx:nginx "${certFile}" "${keyFile}"
      chmod 400 "${certFile}" "${keyFile}"
    '';
    onSuccess = [ "nginx-config-reload.service" ];
    # 只有当 allDomains 列表内容改变时，本 unit 内容才会改变，
    # nixos-rebuild switch 才会重启此服务；否则直接跳过
    restartTriggers = [ (builtins.toJSON allDomains) ];
  };

  # 关联 Nginx 服务依赖
  systemd.services.nginx = {
    wants = [ "generate-mkcert-nginx.service" ];
    after = [ "generate-mkcert-nginx.service" ];
  };

  imports = [
    {
      options.services.nginx.virtualHosts = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            config = {
              forceSSL = lib.mkDefault true;
              sslCertificate = lib.mkDefault certFile;
              sslCertificateKey = lib.mkDefault keyFile;
            };
          }
        );
      };
    }
  ];

  services.nginx = {
    enable = true;
    enableReload = true;
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

  networking.firewall.allowedTCPPorts = [ 443 ];
}
