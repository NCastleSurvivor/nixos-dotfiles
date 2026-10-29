{ pkgs, ... }:
{
  # 非自由软件白名单由 modules/system/packages/apps.nix 统一声明；
  # nvidia-vaapi-driver 等自由软件不放入 unfree 名单。
  environment.systemPackages = with pkgs; [
    alsa-utils # ALSA 底层工具（alsamixer, amixer）
    pavucontrol # PulseAudio 音量控制面板（兼容 PipeWire）
    playerctl # MPRIS 媒体控制
    libva-utils
    vdpauinfo
    nvidia-vaapi-driver
    # 电源/温度
    powertop
    smartmontools
    #agenix加密相关包
    age
    ssh-to-age
    agenix-cli
    # 基础网络工具
    inetutils # ping/telnet 等
    traceroute
    speedtest-cli
    iproute2
    net-tools # ifconfig/netstat（兼容旧脚本）
    ethtool

    # 网络诊断
    nmap
    mtr
    tcpdump
    wireshark-cli
    netcat
    socat
    bind # dig/nslookup
    whois
    aria2

    # 硬件信息
    lshw
    hwinfo
    dmidecode
    pciutils
    usbutils
    udiskie # 由 modules/system/services.nix 的 user service 启动
    polkit_gnome # Polkit 认证代理
    brightnessctl
    acpi
    less
  ];
}
