# modules/desktop/xdg-portal.nix
{ pkgs, ... }:
{
  # ===== XDG 桌面门户 =====
  xdg.portal = {
    enable = true;
    wlr.enable = false; # niri 基于 wlroots，使用 wlr 后端
    #gtkUsePortal = true; # 可选：GTK 程序也走 portal 文件对话框
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # GTK 文件选择器等
      xdg-desktop-portal-gnome
    ];
    config = {
      commn.default = [ "gnome" "gtk" ];
      niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };
}
