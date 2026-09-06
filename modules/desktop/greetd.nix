{ config, pkgs, ... }:
{
  # ===== greetd + tuigreet 登录管理器 =====
  # tuigreet 是 TUI 风格的 Wayland 登录界面
  services.greetd = {
    enable = true;
    settings = {
      user = "greeter";
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd ${pkgs.niri}/bin/niri-session"; 
      };
    };
  };

  environment.systemPackages = [ pkgs.tuigreet ];

  # 禁用其他显示管理器（确保不冲突）
  services.xserver.displayManager.lightdm.enable = false;
  services.displayManager.gdm.enable = false;
  services.displayManager.sddm.enable = false;
}
