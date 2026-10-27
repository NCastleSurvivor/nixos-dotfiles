{
  config,
  pkgs,
  configsDir,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    # 系统模块（包含 modules/system/packages）
    ./modules/system
    # 桌面模块
    ./modules/desktop
  ];

  # ===== 允许非自由软件 =====
  #nixpkgs.config.allowUnfree = true;
  options = {
    myUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "各模块声明的非自由软件包名单，自动聚合后用于 allowUnfreePredicate";
    };
  };
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.myUnfreePackages;

    # 保持安装时的兼容基线；不要为了跟随 unstable 盲目提升。
    # 全新安装可使用 "26.11"，已有系统保持 "26.05"。
    system.stateVersion = "26.05";

    # 启用 Stylix；只写 targets 而不写 enable 时，所有主题目标都会被忽略。
    stylix = {
      enable = true;
      image = ./assets/wallpapers/wall.jpg;
      polarity = "dark";
    };

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
            echo "已替换空目录为符号链接: /etc/nixos -> $NIXOS_CONFIG_HOME"
          fi
        fi
      '';
      deps = [
        "users"
        "groups"
        "specialfs"
      ];
    };
  };
}
