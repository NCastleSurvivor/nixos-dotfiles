{ config, pkgs, ... }:
{
  networking = {
    hostName = "NCastleSurvivor";
    dhcpcd.enable = false;
    useDHCP = false; # 禁用默认 DHCP，由 networkmanager 统一处理

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "systemd-resolved"; # 由resolved接管dns
    };
    # 防火墙
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    proxy =  {
      default = "";
      noProxy = "127.0.0.1,localhost,.localdomain";
        };

    };

  # 启动时不等待网络（dhcpcd 不阻塞启动）
  #systemd.services.dhcpcd-wait-online.enable = false;

  # ============================================================
  # 蓝牙（AX210 集成蓝牙 5.3）及DNS设置
  # ============================================================
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services = {
    blueman.enable = true; # 蓝牙图形前端
    resolved = {
        enable = true;
        settings = {
            Resolve = {
                DNS = [
                    "223.5.5"
                    "1.1.1.1"
                    ];
                FallbackDNS = [
                    "8.8.8.8"
                    "9.9.9.9"
                ];
                Domains= ["~."];
                DNSOverTLS = "opportunistic";
                };
            };
        };
    };
}
