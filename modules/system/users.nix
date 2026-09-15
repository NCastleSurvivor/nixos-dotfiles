{ config, pkgs, ... }:
{
  programs.fish.enable = true;
  users = {
    defaultUserShell = pkgs.fish;
    users.zero = {
      isNormalUser = true;
      description = "zero";
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      shell = pkgs.fish;
      hashedPassword = "$y$j9T$MCyrRlBbhbH7XFwqPXWMD1$Uz6cEK/XAow2CHnPbjUHD.SVBBEMypMgXPHq88OAaU3";
    };
  };
}
