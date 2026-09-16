{ config, pkgs, ... }:
{
  # ===== 会话管理（niri / greetd 依赖） =====
  services.seatd.enable = true;

  # ===== 磁盘自动挂载 =====
  services.udisks2.enable = true;

  # ===== 笔记本电源管理 =====
  services.upower.enable = true;

  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/lib/libexec/pokit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStupSec = 10;
    };
  };

  # ===== 日志大小限制 =====
  services.journald.settings = {
    Journal = {
      SystemMaxUse = "100M";
      Storage = "persistent";
    };
  };
}
