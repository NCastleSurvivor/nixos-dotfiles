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
	hashedPassword = "$y$j9T$6O0ScnCYFw/0yAfEPFay4/$.YLcHeooXolwCUuc3ZK.NVclYMmqn81mCn0sUkgR5N5";
    };
  };
}
