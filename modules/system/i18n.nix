{
  ...
}:

{
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
  console.keyMap = "us";
  networking.timeServers = [
    "0.cn.pool.ntp.org"
    "1.cn.pool.ntp.org"
    "2.cn.pool.ntp.org"
    "3.cn.pool.ntp.org"

    "ntp1.aliyun.com"
    "ntp2.aliyun.com"
    "ntp3.aliyun.com"

    "ntp1.ntsc.ac.cn"
    "ntp2.ntsc.ac.cn"
    "ntp3.ntsc.ac.cn"

    "ntp1.cstnet.cn"
    "ntp2.cstnet.cn"
  ];

  services.htpdate.servers = [
    "www.baidu.com"
  ];
}

