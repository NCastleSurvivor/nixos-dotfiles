{ pkgs, ... }:
{
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
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # 让 udiskie 随图形会话启动，而不是只安装一个不会运行的包。
  systemd.user.services.udiskie = {
    description = "udiskie removable media tray";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
