# 系统模块聚合
{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./power.nix
    ./lix.nix
    ./networking.nix
    ./audio.nix

    ./packages
    ./security
    ./services

    ./environment.nix
    ./i18n.nix
  ];
}
