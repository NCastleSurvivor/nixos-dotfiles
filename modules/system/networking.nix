{ config, pkgs, ... }:
{
  networking = {
    hostName = "NCastleSurvivor";
    dhcpcd.enable = false;
    useDHCP = false; # 禁用默认 DHCP，由 networkmanager 统一处理
    wireless.interfaces.wlan0 = {
        useDHCP = true;
        dhcpcdSettings = ''
            noresolv
            '';
        };
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
    proxy = {
      default = "";
      noProxy = "127.0.0.1,localhost,.localdomain";
    };

  };

  # 启动时不等待网络（dhcpcd 不阻塞启动）
  #systemd.services.dhcpcd-wait-online.enable = false;
  services = {
    resolved = {
      enable = true;
      #DNSSEC = "true";
      settings = {
        Resolve = {
          DNS = [
            "223.5.5.5"
            "1.1.1.1#one.one.one.one"
            "119.29.29.29"
            "8.8.8.8#dns.google"
          ];
          FallbackDNS = [
            "1.0.0.1#one.one.one.one"
            "8.8.4.4#dns.google"
            "114.114.114.114"
          ];
          Domains = [ "~." ];
          DNSOverTLS = "opportunistic";
        };
      };
    };
  };
}
