{ config, pkgs, ... }:
{
  # ===== 会话管理（niri / greetd 依赖） =====
  services.seatd.enable = true;

  # ===== 磁盘自动挂载 =====
  services.udisks2.enable = true;

  # ===== 笔记本电源管理 =====
  services.upower.enable = true;

  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 ={
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

  # ===== XDG 桌面门户 =====
  xdg.portal = {
    enable = true;
    wlr.enable = false;  # niri 基于 wlroots，使用 wlr 后端
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk  # GTK 文件选择器等
      xdg-desktop-portal-gnome  
    ];
    config.commn.default = [ "gnome" "gtk" ];
  };

  # 基础通用工具统一在 home/zero/packages.nix。
  environment.systemPackages = with pkgs; [
    udiskie           # U 盘/移动硬盘自动挂载托盘（配合 udisks2）
    polkit_gnome      # Polkit 认证代理（配合 security.polkit）
    brightnessctl     # 屏幕亮度调节（配合 upower）
    acpi              # 电池/温度信息（配合 upower）
  ];

  # ===== 日志大小限制 =====
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=2week
  '';
}
