{ config, pkgs, lib, ... }:
{
  # ============================================================
  # Lix 包管理器（替代 Nix）
  # ============================================================
  nix = {
    package = pkgs.lix;

    settings = {
      # 启用 flakes 和新 CLI
      # 注意：ca-derivations 已移除——Lix 官方说明重写 CA derivations 期间
      # 不提供可用实现，启用无效且可能引发问题。
      experimental-features = [ "nix-command" "flakes" ];

      # 自动优化 nix store（硬链接去重）
      auto-optimise-store = true;

      # 构建器使用 substitute
      builders-use-substitutes = true;

      # 并发构建数
      max-jobs = "auto";

      # ===== 保留策略（防止回收后重复下载）=====
      keep-outputs = true;
      keep-derivations = true;

      # ============================================================
      # 国内二进制缓存镜像（substituters）
      # ============================================================
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.lzu.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    # ============================================================
    # 自动垃圾回收（nix.gc）
    # ============================================================
    gc = {
      automatic = true;
      dates = "Sun 03:00";
      options = "--delete-older-than 3d";
      persistent = true;
    };
    # ============================================================
    # 自动优化 Nix Store（nix.optimise）
    # ============================================================
    optimise = {
      automatic = false;
    };
  };
  # ============================================================
  # 系统级 nix 工具
  # ============================================================
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt   # nix 代码格式化
    nix-diff      # 对比两个 derivation 差异
    nix-tree      # 交互式依赖树查看

    (writeShellScriptBin "clean-nixos" ''
    set -e

    echo "=== Cleaning user-level generations ==="
    ${nix}/bin/nix-env --delete-generations old

    echo "=== Cleaning system-level generations ==="
    doas ${nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations old

    echo "=== Running garbage collection ==="
    doas ${nix}/bin/nix-collect-garbage -d 2>/dev/null || doas nix-collect-garbage -d

    echo "=== Optimizing Nix store ==="
    doas ${nix}/bin/nix-store --optimize 2>/dev/null || doas nix-store --optimize

    echo "=== Updating bootloader entries ==="
    doas nixos-rebuild boot

    echo "=== System cleanup and boot update completed! ==="
    ''
    )
  ];
}
