# modules/desktop/xdg-portal.nix
{ pkgs, ... }:
{
  # ===== XDG 桌面门户 =====
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # 文件选择器等
      xdg-desktop-portal-gnome # niri 下的 ScreenCast/Screenshot
    ];
    config = {
      common.default = [ "gtk" ];
      niri = {
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
  };
}
