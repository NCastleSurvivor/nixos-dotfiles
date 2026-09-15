{ config, pkgs, configsDir, ... }:
{
  imports = [
    ./hardware-configuration.nix

    # 系统模块
    ./modules/system
    # 桌面模块
    ./modules/desktop
    # 统一软件包组（整合 root 与用户级包，存放于 home/zero/）
    ./home/zero/packages.nix
  ];

  # ===== 允许非自由软件 =====
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";

  # ============================================================
  # NixOS 配置文件映射（Home 分区方案）
  # ============================================================
  system.activationScripts.link-nixos-config = {
    text = ''
      NIXOS_CONFIG_HOME="/home/zero/nixos-configuration"

      # 如果 /etc/nixos 不存在且 home 分区配置存在，则创建符号链接
      if [ ! -e /etc/nixos ] && [ -d "$NIXOS_CONFIG_HOME" ]; then
        ln -s "$NIXOS_CONFIG_HOME" /etc/nixos
        echo "已创建符号链接: /etc/nixos -> $NIXOS_CONFIG_HOME"
      fi

      # 如果 /etc/nixos 是普通目录（非符号链接），且为空，则替换为符号链接
      if [ -d /etc/nixos ] && [ ! -L /etc/nixos ]; then
        if [ -z "$(ls -A /etc/nixos 2>/dev/null)" ]; then
          rmdir /etc/nixos
          ln -s "$NIXOS_CONFIG_HOME" /etc/nixos
          echo "已替换为空目录为符号链接: /etc/nixos -> $NIXOS_CONFIG_HOME"
        fi
      fi
    '';
    deps = [ "users" "groups" "specialfs" ];
  };
}
