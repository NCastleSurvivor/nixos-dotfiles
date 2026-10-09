{
  config,
  pkgs,
  lib,
  ...
}:
{
  myUnfreePackages = [
    "nvidia-vaapi-driver"
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
    "nvidia-firmware"
    "broadcom-bt-firmware"
  ];
  hardware = {

    enableRedistributableFirmware = true;

    cpu.amd.updateMicrocode = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      modesetting.enable = true; # Wayland 必需
      nvidiaSettings = true;
      open = false; # RTX 2060 (Turing) 不支持开源驱动

      powerManagement = {
        enable = true;
        finegrained = true; # 细粒度电源管理
      };

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:6:0:0"; # ← 用 lspci 确认实际 PCI 地址
        nvidiaBusId = "PCI:1:0:0"; # ← 用 lspci 确认实际 PCI 地址
      };
    };

    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # ===== 笔记本电源管理 =====
  powerManagement = {
    enable = true;
    #cpuFreqGovernor = "powersave"; # 已安装tlp，这两项与tlp互斥
    #powertop.enable = true; # powertop 自动调优（正确路径：powerManagement.powertop）
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # TLP 电源管理
  services = {
    blueman.enable = true;
    xserver.videoDrivers = [
      "nvidia"
      "modesetting"
    ];
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        TLP_DEFAULT_MODE = "BAT";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        NVIDIA_SLEEP = "nv";
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
      };
    };
  };
  # ===== 硬件断言 =====
  assertions = [
    {
      assertion = config.hardware.nvidia.modesetting.enable;
      message = "NVIDIA modesetting 必须启用，否则 Wayland/niri 无法使用 NVIDIA GPU";
    }
  ];
}
