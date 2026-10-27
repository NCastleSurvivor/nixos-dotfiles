{ config, pkgs, ... }:
{
  programs.fish.enable = true;
  users = {
    defaultUserShell = pkgs.fish;
    # 密码完全由 agenix 的 zero_password 决定；mutableUsers=false 会在每次
    # activation 同步密码，不允许用 passwd 手工修改。
    mutableUsers = false;
    users.zero = {
      isNormalUser = true;
      description = "zero";
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
      ];
      shell = pkgs.fish;
      hashedPasswordFile = config.age.secrets.zero_password.path;
    };
  };
}
