{ config, pkgs,  ... }:
{
  # ============================================================
  # 桌面配套工具（最小化）
  # 仅保留桌面运行必需的软件，其他请用户自行添加。
  # ============================================================
  environment.systemPackages = with pkgs; [
    niri
    waybar              # 状态栏
    fuzzel              # 应用启动器
    mako                # 通知守护

    # --- 锁屏 / 空闲 / 壁纸 ---
    swaylock-effects    # 锁屏（带模糊/特效）
    swayidle            # 空闲守护（息屏/锁屏/休眠）
    swaybg              # 壁纸设置

    # --- 音量/亮度 OSD ---
    wob                 # Wayland 浮动进度条

    # --- 文件管理器 ---
    pcmanfm-qt          # Qt 文件管理器（轻量、支持挂载）
    peazip              # 跨平台压缩包管理器

    # --- 截图 ---
    grim                # 截图
    slurp               # 框选区域
    wl-clipboard        # 剪贴板（截图复制等）
    wlr-randr        # 显示器信息查看
  ];

  # ===== Qt 程序 Wayland 支持 =====
  environment.variables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  # ===== 桌面门户配置 =====
  xdg.portal.config = {
    common = {
      default = [ "gnome" "gtk" ];
    };
  };
}
