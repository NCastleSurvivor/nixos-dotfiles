{
  config,
  pkgs,
  ...
}:
{
  # ============================================================
  # Lix 包管理器（替代 Nix）
  # ============================================================
  nix = {
    package = pkgs.lix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # 保持沙箱开启；relaxed 会削弱构建隔离，不建议作为默认。
      sandbox = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      max-jobs = "auto";

      # 保留输出和 derivation，避免回收后重复下载。
      keep-outputs = true;
      keep-derivations = true;

      # ============================================================
      # 国内二进制缓存镜像（substituters）
      # ============================================================
      extra-substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.lzu.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://attic.xuyh0120.win/lantian"
        "https://cache.nixos.org/"
      ];

      extra-trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    # 保留足够的回滚窗口；3 天会让一次失败升级很快失去旧代。
    gc = {
      automatic = true;
      dates = "Sun 03:00";
      options = "--delete-older-than 14d";
      persistent = true;
    };
  };

  # ============================================================
  # 系统级 nix 工具
  # ============================================================
  environment.systemPackages = with pkgs; [
    nixfmt-tree
    nix-diff
    nix-tree

    (writeShellScriptBin "clean-nixos" ''
      set -euo pipefail

      echo "=== Cleaning user-level generations ==="
      ${config.nix.package}/bin/nix-env --delete-generations old

      echo "=== Cleaning system-level generations ==="
      doas ${config.nix.package}/bin/nix-env \
        --profile /nix/var/nix/profiles/system --delete-generations old

      echo "=== Running garbage collection ==="
      doas ${config.nix.package}/bin/nix-collect-garbage -d

      echo "=== Optimizing Nix store ==="
      doas ${config.nix.package}/bin/nix-store --optimize

      echo "=== Updating bootloader entries ==="
      doas nixos-rebuild boot --flake /etc/nixos#NCastleSurvivor

      echo "=== System cleanup and boot update completed! ==="
    '')
  ];
}
