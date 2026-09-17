{ pkgs, ...}:
{
    programs.nh = {
        enable = true;
        #设置flake目录路径
        flake = "/home/zero/nixos-configuration/";
        clean = {
            enable = true;
            extraArgs = "--keep-since 3d --keep 2";
        };
    };
}
