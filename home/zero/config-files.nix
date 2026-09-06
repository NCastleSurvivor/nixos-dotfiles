{ config, pkgs, lib, configsDir, ... }:
{
  # ===== 配置文件映射 =====
  # 所有配置文件从 configs/ 目录映射到 ~/.config/
  xdg = {
    configFile = {
      "waybar" = {source = "${configsDir}/waybar"; force = true; recursive = true; };
      "niri" = { source = "${configsDir}/niri"; force = true; recursive = true; };
      "fuzzel" = { source = "${configsDir}/fuzzel"; force = true; recursive = true; };
      "kitty" = { source = "${configsDir}/kitty"; force = true; recursive = true; };
      "mako" = { source = "${configsDir}/mako"; force = true; recursive = true; };
      "swaylock" = { source = "${configsDir}/swaylock"; force = true; recursive = true; };
      "nvim" = { source = "${configsDir}/nvim"; force = true; recursive = true; };
    };

    dataFile = {
    "fcitx5/rime" = { source = "${configsDir}/rime"; force = true; recursive =true; };
    };
  };

  fonts = lib.mkForce {
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Sarasa Gothic SC"
        ];
        monospace = [
          "Maple Mono NF CN"
        ];

        emoji = [
          "Noto Color Emoji"
        ];
      };
    };
  };

}
