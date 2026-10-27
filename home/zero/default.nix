{
  lib,
  ...
}:
{
  imports = [
    # 系统级软件包已移到 modules/system/packages；
    # 这里只保留 Home Manager 用户级配置。
    ./shell.nix
    ./git.nix
    ./nh.nix
    ./xdg.nix
    ./rime.nix
    ./fonts.nix
    ./desktop/noctalia.nix
    ./desktop/zen-browser.nix
  ];

  # ===== 用户基本信息 =====
  home = {
    username = "zero";
    homeDirectory = "/home/zero";
    # 保持安装时的兼容基线；新装机再考虑 26.11。
    stateVersion = "26.05";

    sessionVariables = {
      TERMINAL = "kitty";
      PAGER = "less";
      LESS = "-R";
    };

    # 激活时执行的命令
    activation = {
      createDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $HOME/{Downloads,Documents,Music,Pictures,Videos,Projects,Workspace}
      '';
    };
  };

  programs.home-manager.enable = true;
}
