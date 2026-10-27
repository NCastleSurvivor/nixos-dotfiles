# 桌面模块聚合
{ ... }:
{
  imports = [
    ./display-manager/greetd.nix
    ./wayland/niri.nix
    ./wayland/xdg-portal.nix
    ./input/fcitx.nix
  ];
}
