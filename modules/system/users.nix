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
	hashedPassword = "！";
    };
  };
}
