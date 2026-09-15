{ config, pkgs, ... }:
{
  # ============================================================
  # niri Wayland 平铺合成器 + xwayland-satellite
  # 该文件内仅包含niri桌面管理器及其必要配置软件，仅为niri桌面服务
  # ============================================================

  # XWayland 兼容：使用 xwayland-satellite（独立卫星进程）
  # 禁用合成器内置的 XWayland，改用 xwayland-satellite
  programs.xwayland.enable = true;
  services.xserver.enable = false;
  # Wayland 全局环境变量
  environment.sessionVariables = {
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    NIXOS_OZONE_WL = "1";
  };
  environment.systemPackages = with pkgs;[
    xwayland-satellite
    niri
    waybar
    fuzzel
    mako

    # --- 锁屏 / 空闲 / 壁纸 ---
    swaylock-effects # 锁屏（带模糊/特效）
    swayidle # 空闲守护（息屏/锁屏/休眠）
    awww # 壁纸设置

    # --- 截图 ---
    grim # 截图
    slurp # 框选区域
    wl-clipboard # 剪贴板（截图复制等）
    # --- 音量/亮度 OSD ---
    wob # Wayland 浮动进度条
  ];

  # ===== Qt 程序 Wayland 支持 =====
  environment.variables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };
}
