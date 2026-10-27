# 笔记本电源管理：TLP、zram、通用电源选项
{ ... }:
{
  powerManagement = {
    enable = true; # 默认即为 true，保留显式写法的可读性
    # cpuFreqGovernor 与 powertop 自动调优交给 TLP，避免重复管理。
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  services.tlp = {
    enable = true;
    settings = {
      TLP_DEFAULT_MODE = "BAT";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      NVIDIA_SLEEP = "nv_drm"; # 若 tlp-stat 报错，按当前 TLP 版本改为 nv/1
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };
}
