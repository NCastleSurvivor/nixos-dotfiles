{
  config,
  pkgs,
  inputs,
  ...
}:
{
  myUnfreePackages = [
    "wechat-uos"
    "qq"
    "p7zip"
    "unrar"
    "wpsoffice-cn"
  ];
  environment.systemPackages = with pkgs; [
    kitty
    yazi
    lsof
    unrar
    p7zip
    libnotify
    xdg-utils
    delta

    wechat-uos
    qq
    #尝试引入 noctalia、mark-shot代替mako、waybar等
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default

    #nh相关
    nix-output-monitor
    nvd

    # ----- 基础命令行工具（系统运维必需）-----
    wget
    curl
    git
    htop
    ripgrep # 更快的 grep（neovim 插件依赖）
    fd # 更快的 find（neovim 插件依赖）
    jq # JSON 处理（waybar 自定义模块依赖）
    tree
    man-pages
    man-pages-posix

    # ----- 别名依赖（environment.shellAliases 中引用）-----
    eza # ls/ll/la 别名
    bat # cat 别名

    # ----- 磁盘/文件系统 -----
    exfatprogs
    dosfstools
    parted
    gptfdisk

    android-tools
    # ----- 编辑器 -----
    neovim
    nodejs
    python3
    gapless

    # about wps and lx-music work in x11 environment
    # lx-music-desktop：歌词窗口在 Wayland 下损坏，强制 X11 模式
    (pkgs.writeShellScriptBin "lx-music" ''
      exec ${pkgs.lx-music-desktop}/bin/lx-music-desktop --ozone-platform=x11 "$@"
    '')

    # wpsoffice-cn：Qt 应用在 Wayland 下可能有渲染问题，强制 X11
    (pkgs.writeShellScriptBin "wps" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.wpsoffice-cn}/bin/wps "$@"
    '')
    (pkgs.writeShellScriptBin "wpp" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.wpsoffice-cn}/bin/wpp "$@"
    '')
    (pkgs.writeShellScriptBin "et" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.wpsoffice-cn}/bin/et "$@"
    '')
    (pkgs.writeShellScriptBin "wpp" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.wpsoffice-cn}/bin/wpp "$@"
    '')
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    maple-mono.NF-CN-unhinted
    font-awesome
    powerline-symbols
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
    sarasa-gothic
    wqy_zenhei
    noto-fonts-color-emoji
  ];
}
