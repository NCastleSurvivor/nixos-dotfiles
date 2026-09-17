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
      hashedPassword = "$y$j9T$M3XOK5bP.shzKUA4apcvP0$SLZzVNDvXQSOVe6EC9UINvUk3UQbvak0NPit/bocpU3";
    };
  };
}
