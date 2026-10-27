{ ... }:
{
  programs.nh = {
    enable = true;
    flake = "/home/zero/nixos-configuration/";
    clean = {
      enable = true;
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
}
