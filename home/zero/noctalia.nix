{ pkgs, inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    settings = {
      compositor = {
        name = "niri";
      };

      location = {
            auto_locate = false;
            address = "suzhou, JiangSu, China";
    };
      weather = {
            enabled = true;
            refresh_minutes = 30;
            unit = "metric";
            effects = true;
        };
      bar = {
        position = "top";
        height = 36;
        margin = {
          top = 8;
          left = 12;
          right = 12;
        };
        transparent = true;

        modules = {
          left = [
            "workspaces"
            "active-window"
          ];
          center = [
            "clock"
          ];
          right = [
            "tray"
            "weather"
            "volume"
            "network"
            "battery"
            "control-center-toggle"
          ];
        };
      };

      workspaces = {
        showIcons = true;
        hideEmpty = false;
      };

      controlCenter = {
        position = "right";
        cards = [
          "media-player"
          "sliders"
          "quick-toggles"
        ];
      };

      notifications = {
        enable = true;
        anchor = "top-right";
        timeout = 5000;
        maxCount = 5;
      };

      wallpaper = {
        enable = true;
        mode = "fill";

        directory = "/home/zero/Pictures/Wallpapers";
        per_monitor_directories = false;

        default = {
                path = "/home/zero/Pictures/Wallpapers/default.jpg";
            };

        automation = {
                enabled = true;
                interval_seconds = 300;
                order = "random";
                recursive = false;
            };
        transition = [ "fade" "wipe" "disc" "stripes" "zoom" "honeycomb" ];
        transition_duration = 1500;
        transition_on_startup = false;
      };
      theme = {
        colorScheme = "dark";
        useWallpaperColors = true;
      };
    };
  };
}
