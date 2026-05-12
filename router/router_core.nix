{ config, lib, pkgs, ... }:

{

  # 启用 IP 转发
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.forwarding" = 1;
    # 开启 BBR
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  networking.useDHCP = false; # 全局禁用 useDHCP，因为我们将在 networkd 中手动配置
  networking.useNetworkd = true;

  # 配置两个网口
  systemd.network = {
    enable = true;
    # WAN 口 (end0) - 从光猫获取 IP
    networks."10-wan" = {
      matchConfig.Name = "end0";
      networkConfig = {
        DHCP = "ipv4";
        IPv4Forwarding = "yes";
      };
      # 如果光猫改了桥接，则在此处配置拨号，当前按你要求直接连光猫
      dhcpV4Config.RouteMetric = 10;
    };
    # LAN 口 (enu1) - 静态 IP 10.8.8.8
    networks."20-lan" = {
      matchConfig.Name = "enu1";
      address = [ "10.8.8.8/24" ];
      networkConfig = {
        IPv4Forwarding = "yes";
        DHCPServer = "yes";
      };
      dhcpServerConfig = {
        PoolOffset = 10;
        PoolSize = 200;
        EmitDNS = "yes";
        DNS = [ "10.8.8.8" ]; # 让客户端使用路由器作为 DNS
      };
    };
  };

  # 配置NAT
  networking.nat = {
    enable = true;
    externalInterface = "end0"; # 替换为您的实际WAN口名称
    internalInterfaces = [ "enu1" ]; # 替换为您的实际LAN口名称
  };

  # 配置防火墙
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = lib.mkForce [ ];
  networking.firewall.allowedUDPPorts = lib.mkForce [ ];
  networking.firewall.interfaces."enu1" = {
    allowedTCPPorts = [
      22 # ssh
      53 # dns
      67
      68
      80
      3000 # adguardhome
    ];
    allowedUDPPorts = [
      53
      67
    ];
  };

  # SmartDNS 服务配置
  services.smartdns = {
    enable = true;
    bindPort = 5300;
    settings = {
      prefetch-domain = true;
      speed-check-mode = "tcp:443,tcp:80,ping";
      log-level = "info";
      server-https = [
        "https://1.0.0.1/dns-query"
        "https://1.1.1.1/dns-query"
        "https://185.222.222.222/dns-query"
        "https://cloudflare-dns.com/dns-query -exclude-default-group"
      ];
      server-tls = [
        "8.8.8.8:853"
        "1.1.1.1:853"
      ];
      server = [
        "202.101.172.35 -group china -exclude-default-group"
        "202.101.172.47 -group china -exclude-default-group"
        "114.114.114.114 -group china -exclude-default-group"
        #"2a0c:b641:69c:7864:0:5:0:3"
      ];
    };
  };

  # AdGuard Home 需要监听在 10.8.8.8:53，因为 DHCP 已经告知客户端 DNS 是 10.8.8.8
  # 然后 AdGuard Home 将 DNS 请求转发给 SmartDNS (10.8.8.8:5300)
  services.adguardhome = {
    enable = true;
    openFirewall = false;

    settings = {
      dns = {
        bind_hosts = [
          "10.8.8.8"
          "127.0.0.1"
        ];
        port = 53;
        # 配置上游为 SmartDNS
        upstream_dns = [
          "127.0.0.1:5300"
        ];
      };
    };
  };

}
