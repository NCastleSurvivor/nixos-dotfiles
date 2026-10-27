{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # 外部 Noctalia 模块会禁用 HM 内置的 programs.noctalia 模块，
  # 避免同名 option 冲突；这里显式启用并生成 Noctalia v5 的 TOML 配置。
  programs.noctalia = {
    enable = true;
    # 包已在 environment.systemPackages 中安装，保证 niri 直接 spawn 能找到；
    # 这里只生成配置，避免同一个包被 HM 再安装一次。
    package = null;

    settings = {
      # ------------------------------------------------------------------
      # 顶栏：start / center / end 是 v5 的 widget 列表（旧版 bar.modules 已移除）
      # ------------------------------------------------------------------
      bar = {
        default = {
          position = "top";
          thickness = 36;
          margin_ends = 12;
          margin_edge = 8;
          background_opacity = 0.92;
          start = [
            "launcher"
            "workspaces"
            "weather"
          ];
          center = [ "clock" ];
          end = [
            "tray"
            "network"
            "bluetooth"
            "volume"
            "battery"
            "control-center"
            "session"
          ];
        };
      };

      # ------------------------------------------------------------------
      # 单 widget 配置
      # ------------------------------------------------------------------
      widget = {
        weather = {
          max_length = 180;
          show_condition = true;
          show_temperature = true;
        };
        "control-center" = {
          glyph = "noctalia";
        };
      };

      # ------------------------------------------------------------------
      # 控制中心
      # ------------------------------------------------------------------
      control_center = {
        sidebar = "compact";
        show_shortcut_labels = true;
        show_session_button = true;
        media.show_visualizer = true;
      };

      # ------------------------------------------------------------------
      # 天气 + 位置（天气启用后，Control Center 会自动出现 Weather 标签）
      # ------------------------------------------------------------------
      weather = {
        enabled = true;
        refresh_minutes = 30;
        unit = "metric";
        effects = true;
      };

      location = {
        auto_locate = false;
        address = "Suzhou, Jiangsu, China";
      };

      # ------------------------------------------------------------------
      # 壁纸轮播
      # ------------------------------------------------------------------
      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        directory = "/home/zero/Pictures/Wallpapers";
        transition = [
          "fade"
          "wipe"
          "disc"
          "stripes"
          "zoom"
          "honeycomb"
        ];
        transition_duration = 1500;
        transition_on_startup = true;

        default = {
          path = "/home/zero/Pictures/Wallpapers/default.jpg";
        };

        automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
          recursive = false;
          pause_on_fullscreen = true;
        };
      };

      # ------------------------------------------------------------------
      # 主题
      # ------------------------------------------------------------------
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };
}
