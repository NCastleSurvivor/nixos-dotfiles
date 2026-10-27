{ ... }:
{
  # ============================================================
  # 全局环境变量
  # 软件包已整合至 home/zero/packages.nix（environment.systemPackages）。
  # ============================================================

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    # Zen Browser（twilight 分支）的可执行文件名为 zen-twilight。
    BROWSER = "zen-twilight";
    PAGER = "less";
  };
}
