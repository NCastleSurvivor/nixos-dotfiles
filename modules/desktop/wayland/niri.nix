{ pkgs, ... }:
{
  services.xserver.enable = false;

  # Wayland 会话环境变量
  environment.sessionVariables = {
    GDK_BACKEND = "wayland,x11";
    # 允许 Qt 程序在 Wayland 不可用时回退到 X11，而不是直接失败。
    QT_QPA_PLATFORM = "wayland;xcb";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    niri
    fuzzel
    xwayland-satellite # 由 niri 的 spawn-at-startup 启动
    swaylock-effects
    swayidle
  ];

  # Qt 程序 Wayland 支持
  environment.variables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };
}
