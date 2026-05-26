#!/usr/bin/env bash
DOMAINS=(
    "*.home"
    "localhost"
    "127.0.0.1"
    "::1"
)

# 添加你当前配置的所有子域名
DOMAINS+=(
    "home"
    "actual.home"
    "adguard.home"
    "beszel.home"
    "book.home"
    "booklore.home"
    "calibre.home"
    "clash.home"
    "dev.home"
    "docker.home"
    "dockge.home"
    "file.home"
    "gitness.home"
    "grafana.home"
    "hoppscotch.home"
    "jupyterlab.home"
    "kavita.home"
    "link.home"
    "memos.home"
    "money.home"
    "netdata.home"
    "nginx.home"
    "pdf.home"
    "plex.home"
    "readeck.home"
    "reader.home"
    "router.home"
    "scrutiny.home"
    "status.home"
    "webdav.home"
    "wifi.home"
    "xiaoya.home"
)

mkcert -cert-file home/secrets/home.pem -key-file home/secrets/home-key.pem "${DOMAINS[@]}"
sops -e home/secrets/home.pem > home/secrets/home.pem.asc && rm home/secrets/home.pem
sops -e home/secrets/home-key.pem > home/secrets/home-key.pem.asc && rm home/secrets/home-key.pem

# 在 dotfiles/nixos 目录下执行 ./home/generate_nginx_ssl.sh
