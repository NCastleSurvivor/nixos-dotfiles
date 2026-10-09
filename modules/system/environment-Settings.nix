{ config, pkgs, ... }:
{
  # ============================================================
  # 全局环境变量与 Shell 别名
  # 软件包已整合至 home/zero/packages.nix（environment.systemPackages）。
  # ============================================================

  # ===== 全局环境变量 =====
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "chromium";
    #TERM = "xterm-kitty";
    PAGER = "less";
  };
}
