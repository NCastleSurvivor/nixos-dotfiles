# 系统模块聚合 — 自动引入本目录下所有模块
{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./lix.nix
    ./doas.nix
    ./networking.nix
    ./audio.nix
    ./services.nix
    ./packages.nix
    ./i18n.nix
    ./users.nix
  ];
}
