{ config, pkgs, ... }:
{
  networking = {
    hostName = "NCastleSurvivor";
    dhcpcd.enable = false;
    useDHCP = false;  # 禁用默认 DHCP，由 dhcpcd 统一处理
    
    networkmanager = {
	enable = true;
	wifi.backend = "iwd";
    };
    # 防火墙
    firewall = {
    	enable = true;
    	allowedTCPPorts = [];
    	allowedUDPPorts = [];
	};
     nameservers = [
	"223.5.5.5"
	"223.6.6.6"
	"119.29.29.29"
	"1.1.1.1"
     ];
  };

  # 启动时不等待网络（dhcpcd 不阻塞启动）
  systemd.services.dhcpcd-wait-online.enable = false;


  # ============================================================
  # 蓝牙（AX210 集成蓝牙 5.3）
  # ============================================================
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;  # 蓝牙图形前端

  # ============================================================
  # 网络工具
  # ============================================================
  environment.systemPackages = with pkgs; [
    # 基础网络工具
    inetutils          # ping/telnet 等
    dnsutils           # dig/nslookup
    traceroute
    speedtest-cli
    iproute2           # ip 命令
    net-tools          # ifconfig/netstat（兼容旧脚本）
    ethtool            # 网卡信息/配置

    # 网络诊断
    nmap
    mtr
    tcpdump
    wireshark-cli
    netcat
    socat
    bind               # dig/nslookup（完整包）
    whois
    aria2              # 多线程下载
  ];

}
