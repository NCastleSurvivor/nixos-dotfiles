{ config, pkgs, ... }:
{
  # 除了 doas。nix外其余移至此处
  environment.systemPackages = with pkgs; [
    alsa-utils # ALSA 底层工具（alsamixer, amixer）
    pavucontrol # PulseAudio 音量控制面板（兼容 PipeWire）
    playerctl # MPRIS 媒体控制
    pamixer # 命令行音量控制（waybar 模块用）
    nvidia-vaapi-driver
    libva-utils
    vdpauinfo

    # 电源/温度
    powertop
    tlp
    smartmontools

    # 基础网络工具
    inetutils # ping/telnet 等
    traceroute
    speedtest-cli
    iproute2 # ip 命令
    net-tools # ifconfig/netstat（兼容旧脚本）
    ethtool # 网卡信息/配置

    # 网络诊断
    nmap
    mtr
    tcpdump
    wireshark-cli
    netcat
    socat
    bind # dig/nslookup（完整包）
    whois
    aria2 # 多线程下载

    # 硬件信息
    lshw
    hwinfo
    dmidecode
    pciutils
    usbutils
    udiskie # U 盘/移动硬盘自动挂载托盘（配合 udisks2）
    polkit_gnome # Polkit 认证代理（配合 security.polkit）
    brightnessctl # 屏幕亮度调节（配合 upower）
    acpi # 电池/温度信息（配合 upower）

  ];
}
