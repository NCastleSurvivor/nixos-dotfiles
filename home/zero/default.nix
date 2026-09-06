{ config, pkgs, lib, ... }:
{
  imports = [
    # packages.nix 已提升为 NixOS 系统模块（environment.systemPackages），
    # 在 configuration.nix 中直接 import，不再作为 Home Manager 模块导入。
    ./shell.nix
    ./config-files.nix
    ./programs.nix
  ];

  # ===== 用户基本信息 =====
  home = {
    username = "zero";
    homeDirectory = "/home/zero";
    stateVersion = "26.05";

    sessionVariables = {
      TERMINAL = "kitty";
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "zen";
      PAGER = "less";
      LESS = "-R";
    };

    # 激活时执行的命令
    activation = {
      # 确保用户目录存在
      createDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $HOME/{Downloads,Documents,Music,Pictures,Videos,Projects,Workspace}
      '';
    };
  };

  # ===== Home Manager  =====
  programs.home-manager.enable = true;

}
