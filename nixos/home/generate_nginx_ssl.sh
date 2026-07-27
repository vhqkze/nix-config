#!/usr/bin/env bash
# 以下命令都在 dotfiles/nixos 目录下执行
# 使用 `CAROOT=$(pwd)/home/secrets mkcert -install` 生成根证书后，使用sops加密
# sops --encrypt home/secrets/rootCA-key.pem > home/secrets/mkcert-key.pem.asc
# sops --encrypt home/secrets/rootCA.pem > home/secrets/mkcert-ca.pem.asc
# 然后就可以使用 rm home/secrets/rootCA-key.pem 删除私钥文件了，私钥文件永远不要发到其他地方
# 然后先执行 nixos-rebuild 将根证书安装到系统
# 然后执行 ./home/generate_nginx_ssl.sh 重新生成 nginx 证书（如果在 nixos-rebuild 之前执行，生成的证书是错误的）
#
# 如果重新生成了根证书，需要将 rootCA.pem 传送到局域网内其他设备，安装并信任
# macos: 打开 钥匙串访问，点击左侧的 默认钥匙串/登录，将 rootCA.pem 拖进来，双击打开详情，修改为 始终信任。
# ios: 隔空投送到 ios 设备，然后打开 ios 设备的设置，顶部会显示已下载描述文件，进去安装下，然后进入 通用/关于手机，底部证书信任设置里信任它。

DOMAINS=(
    "*.home"
    "localhost"
    "127.0.0.1"
    "::1"
)

# 添加你当前配置的所有子域名
DOMAINS+=(
    "home"
    "adguard.home"
    "beszel.home"
    "book.home"
    "calibre.home"
    "clash.home"
    "docker.home"
    "file.home"
    "kavita.home"
    "link.home"
    "memos.home"
    "money.home"
    "plex.home"
    "pocket-id.home"
    "readeck.home"
    "reader.home"
    "router.home"
    "status.home"
    "webdav.home"
    "wifi.home"
)

mkcert -cert-file home/secrets/home.pem -key-file home/secrets/home-key.pem "${DOMAINS[@]}"
sops -e home/secrets/home.pem > home/secrets/home.pem.asc && rm home/secrets/home.pem
sops -e home/secrets/home-key.pem > home/secrets/home-key.pem.asc && rm home/secrets/home-key.pem

# 在 dotfiles/nixos 目录下执行 ./home/generate_nginx_ssl.sh
