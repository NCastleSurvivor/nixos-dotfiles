# 系统字体
{ pkgs, ... }:
{
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
