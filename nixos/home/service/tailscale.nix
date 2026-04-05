{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # 需要开启ip转发，要不然tailscale的子网路由功能无法使用
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # 开启子网路由功能，首次启动后，需要进入 https://login.tailscale.com/admin/machines 批准下
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-routes=10.8.8.0/24" ];
  };
}
