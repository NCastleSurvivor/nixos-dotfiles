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
    BROWSER = "zen";
    #TERM = "xterm-kitty";
    PAGER = "less";
  };

  # ===== 全局 shell 别名 =====
  environment.shellAliases = {
    ls = "eza --icons=auto";
    ll = "eza -l --icons=auto --git";
    la = "eza -a --icons=auto";
    cat = "bat --plain";
    grep = "rg";
    find = "fd";
    df = "df -h";
    du = "du -h";
    mkdir = "mkdir -pv";
  };
}
