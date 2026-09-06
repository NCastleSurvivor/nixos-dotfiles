# 桌面模块聚合
{ ... }:
{
  imports = [
    ./greetd.nix
    ./niri.nix
    ./fcitx.nix
    ./niriPackages.nix
  ];
}
