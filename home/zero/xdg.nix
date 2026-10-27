# XDG 配置文件映射
{ configsDir, ... }:
{
  xdg.configFile = {
    "niri" = {
      source = "${configsDir}/niri";
      force = true;
      recursive = true;
    };
    "fuzzel" = {
      source = "${configsDir}/fuzzel";
      force = true;
      recursive = true;
    };
    "kitty" = {
      source = "${configsDir}/kitty";
      force = true;
      recursive = true;
    };
    "swaylock" = {
      source = "${configsDir}/swaylock";
      force = true;
      recursive = true;
    };
    "nvim" = {
      source = "${configsDir}/nvim";
      force = true;
      recursive = true;
    };
  };
}
