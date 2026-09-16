host := `hostname`
sudo := if `id -u` == "0" { "" } else { "sudo" }

# 默认应用配置并切换
default: switch

# ==============================================================================
# 系统构建与切换 (Rebuild & Switch)
# ==============================================================================

# 应用配置并切换（默认当前机器，可指定 host: just switch hostname）
switch host=host:
    @echo "==> 正在构建并应用主机 [{{ host }}] 的配置..."
    {{ sudo }} nixos-rebuild switch --flake .#{{ host }}

# 测试配置（立即生效但不写入引导项，重启后还原）
test host=host:
    @echo "==> 正在测试主机 [{{ host }}] 的配置..."
    {{ sudo }} nixos-rebuild test --flake .#{{ host }}

# 写入下次引导项但不立即切换当前环境
boot host=host:
    @echo "==> 正在将主机 [{{ host }}] 的配置写入引导..."
    {{ sudo }} nixos-rebuild boot --flake .#{{ host }}

# 仅构建系统闭包（输出结果至 ./result，用于测试是否能成功编译）
build host=host:
    @echo "==> 正在构建主机 [{{ host }}] 的系统闭包..."
    nix build .#nixosConfigurations.{{ host }}.config.system.build.toplevel

# 查看修改后将带来的包变动（需要系统中安装了 nvd）
diff host=host:
    @echo "==> 正在构建并对比 [{{ host }}] 与当前系统的差异..."
    nix build .#nixosConfigurations.{{ host }}.config.system.build.toplevel --no-link
    nvd diff /run/current-system $(nix path-info .#nixosConfigurations.{{ host }}.config.system.build.toplevel)

# ==============================================================================
# 远程部署 (Remote Deploy)
# ==============================================================================

# 远程部署，用法: just deploy my-remote-server [target-ssh-user-and-ip]
deploy target host=target:
    @echo "==> 正在向远程主机 [{{ target }}] 部署配置 [{{ host }}]..."
    nixos-rebuild switch --flake .#{{ host }} --target-host {{ target }}

# ==============================================================================
# Flake 依赖管理 (Flake Inputs)
# ==============================================================================

# 更新 flake.lock 中的所有 inputs
update *inputs:
    @echo "==> 正在更新所有 flake inputs..."
    nix flake update {{ inputs }}

# 检查 flake 语法及有效性
check:
    @echo "==> 正在检查 flake 配置..."
    nix flake check

# 更新所有 flake inputs 并应用配置
upgrade: update switch

# ==============================================================================
# 系统维护与垃圾回收 (Maintenance & Cleanup)
# ==============================================================================

# 查看当前系统的世代历史 (Generations)
history:
    nixos-rebuild list-generations

# 清理垃圾：只保留最近 7 天的世代，其余全部删除
clean age="7d":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> 准备清理超过 {{ age }} 的历史版本..."
    if [ "$(id -u)" -eq 0 ]; then
        # 当前为 root 用户，只需要执行一次系统级清理
        echo "--> 检测到当前为 root 用户，正在执行系统级 GC..."
        nix-collect-garbage --delete-older-than "{{ age }}"
    else
        # 当前为普通用户，先清理普通用户配置，再 sudo 清理系统级配置
        echo "--> 检测到当前为普通用户，正在清理用户级 Profile..."
        nix-collect-garbage --delete-older-than "{{ age }}"
        echo "--> 正在通过 sudo 清理系统级 Profile..."
        sudo nix-collect-garbage --delete-older-than "{{ age }}"
    fi
    echo "==> 清理完成！"

# 深度清理：删除全部历史世代
clean-all: (clean "0d")
