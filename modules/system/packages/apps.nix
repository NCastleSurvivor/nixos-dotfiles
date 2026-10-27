# 系统软件包组：应用、非自由软件、桌面工具
{
  pkgs,
  inputs,
  ...
}:
{
  myUnfreePackages = [
    "wechat-uos"
    "qq"
    "unrar"
    "wpsoffice-cn"
  ];

  environment.systemPackages = with pkgs; [
    kitty
    yazi
    lsof
    unrar
    p7zip
    unzip
    libnotify
    xdg-utils
    delta

    wechat-uos
    qq
    # Noctalia 在系统层安装，确保 niri 直接 spawn 时一定能在 PATH 中找到；
    # HM 侧只负责生成配置，package 设为 null 避免重复安装。
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default

    # nh 相关
    nix-output-monitor
    nvd

    # ----- 基础命令行工具 -----
    wget
    curl
    git
    htop
    ripgrep
    fd
    jq
    tree
    man-pages
    man-pages-posix

    # ----- 别名依赖 -----
    eza
    bat

    # ----- 磁盘/文件系统 -----
    exfatprogs
    dosfstools
    parted
    gptfdisk

    android-tools

    # ----- 编辑器 -----
    neovim
    imagemagick # image.nvim 的 magick 后端
    nodejs
    python3
    gapless

    # WPS / lx-music 的 X11 兼容包装
    go-musicfox
    wpsoffice-cn

    (pkgs.writeShellScriptBin "lx-music" ''
      exec ${pkgs.lx-music-desktop}/bin/lx-music-desktop --ozone-platform=x11 "$@"
    '')

    (pkgs.writeShellScriptBin "wps" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.wpsoffice-cn}/bin/wps "$@"
    '')
    (pkgs.writeShellScriptBin "wpp" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.wpsoffice-cn}/bin/wpp "$@"
    '')
    (pkgs.writeShellScriptBin "et" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.wpsoffice-cn}/bin/et "$@"
    '')
  ];
}
