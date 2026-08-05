{
  config,
  pkgs,
  ...
}:
{
  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    environmentFile = config.sops.secrets.garage.path;
    settings = {
      replication_factor = 1;
      rpc_bind_addr = "127.0.0.1:3901";
      rpc_public_addr = "127.0.0.1:3901";
      s3_api = {
        s3_region = "garage";
        api_bind_addr = "127.0.0.1:3900";
        root_domain = ".s3.garage.home";
      };
      s3_web = {
        bind_addr = "127.0.0.1:3902";
        root_domain = ".web.garage.home";
        index = "index.html";
      };
      admin = {
        api_bind_addr = "127.0.0.1:3903";
      };
    };
  };

  # 详细文档
  # https://garagehq.deuxfleurs.fr/documentation/quick-start/

  # 服务首次部署后，需要分配容量
  # 先检查状态，获取 node_id
  # sudo garage status
  # 然后分配10GB容量，其中 f28d472dac6a5896 换成上一步返回的 node_id
  # 后面容量不够了，也可以再次执行这个命令，分配更多容量
  # sudo garage layout assign --zone dc1 --capacity 10G f28d472dac6a5896
  # 查看变更，同时也是查看当前 version，命令输出里也会显示要应用变更需要执行的命令
  # sudo garage layout show
  # 应用变更
  # sudo garage layout apply --version 1

  # 创建 bucket
  # sudo garage bucket create my-bucket
  # 创建key
  # sudo garage key create my-key-name
  # 授权
  # sudo garage bucket allow my-bucket --read --write --key my-key-name

  # 查看key，带上 --show-secret 可以显示 secret key
  # sudo garage key info memosu --show-secret

  services.nginx.virtualHosts =
    let
      proxy =
        port: extra:
        {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString port}";
            extraConfig = ''
              client_max_body_size 0;
            '';
          };
          forceSSL = true;
          sslCertificate = config.sops.secrets."nginx/home.pem".path;
          sslCertificateKey = config.sops.secrets."nginx/home-key.pem".path;
        }
        // extra;
    in
    {
      "s3.garage.home" = proxy 3900 {
        serverAliases = [ "*.s3.garage.home" ];
      };
      "web.garage.home" = proxy 3902 {
        serverAliases = [ "*.web.garage.home" ];
      };
      "admin.garage.home" = proxy 3903 { };
    };
}
