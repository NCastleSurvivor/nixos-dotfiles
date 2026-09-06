{ config, pkgs, ... }:
{
  # ============================================================
  # niri Wayland 平铺合成器 + xwayland-satellite
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
  ];
}
