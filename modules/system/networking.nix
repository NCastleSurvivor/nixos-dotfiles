{ ... }:
{
  networking = {
    hostName = "NCastleSurvivor";
    dhcpcd.enable = false;
    useDHCP = false; # 由 NetworkManager 统一处理

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "systemd-resolved"; # DNS 由 systemd-resolved 接管
    };

    firewall.enable = true;
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "223.5.5.5"
        "1.1.1.1#one.one.one.one"
        "119.29.29.29"
      ];
      FallbackDNS = [
        "1.0.0.1#one.one.one.one"
        "8.8.4.4#dns.google"
        "8.8.8.8#dns.google"
      ];
      Domains = [ "~." ];
      DNSOverTLS = "opportunistic";
    };
  };
}
