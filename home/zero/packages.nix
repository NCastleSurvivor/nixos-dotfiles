{ config, pkgs, inputs, ... }:
{
  # ============================================================
  # 统一软件包组（系统级，所有用户可用）
  # ============================================================

  environment.systemPackages = with pkgs; [
    # ----- 基础命令行工具（系统运维必需）-----
    wget
    curl
    git
    htop
    ripgrep          # 更快的 grep（neovim 插件依赖）
    fd               # 更快的 find（neovim 插件依赖）
    jq               # JSON 处理（waybar 自定义模块依赖）
    unzip
    p7zip
    tree
    man-pages
    man-pages-posix
    
    # zen 浏览器
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    
    # ----- 别名依赖（environment.shellAliases 中引用）-----
    eza              # ls/ll/la 别名
    bat              # cat 别名

    # ----- 磁盘/文件系统 -----
    exfatprogs
    dosfstools
    parted
    gptfdisk

    # ----- 硬件信息/诊断 -----
    dmidecode

    # ----- 编辑器 -----
    neovim
    nodejs
    python3
    # 社交软件及音乐播放器
    qq
    wechat-uos
    gapless
  ];
  fonts.packages = with pkgs; [
     font-awesome
     powerline-symbols
     nerd-fonts.iosevka
     nerd-fonts.symbols-only
     sarasa-gothic
     wqy_zenhei
     noto-fonts-color-emoji
  ];
}
