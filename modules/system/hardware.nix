{ config, pkgs, lib, ... }:
{
  # ============================================================
  # 硬件配置：AMD R7-4800H + NVIDIA RTX 2060 + Intel AX210
  #
  # 注意：以下公共项统一在 boot.nix 中设置，不在此重复定义：
  #   - boot.kernelParams（含 nvidia/amdgpu/mitigations 等）
  #   - boot.initrd.kernelModules（含 nvidia 模块）
  #   - boot.kernelModules（含 kvm-amd/iwlwifi/iwlmvm/ntfs3）
  # 固件（hardware.enableAllFirmware / hardware.firmware）已从 boot.nix 移至本文件。
  # 蓝牙统一在 networking.nix 中设置。
  # ============================================================
  hardware = {

    enableAllFirmware = true;
    firmware = with pkgs;[
      linux-firmware
    ];

    cpu.amd.updateMicrocode = true;

    nvidia = {
      #enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      modesetting.enable = true;      # Wayland 必需
      nvidiaSettings = true;
      open = true;                    # RTX 2060 (Turing) 不支持开源驱动

      powerManagement = {
        enable = true;
        finegrained = true;           # 细粒度电源管理
      };

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
          };
        amdgpuBusId = "PCI:6:0:0";    # ← 用 lspci 确认实际 PCI 地址
        nvidiaBusId = "PCI:1:0:0";     # ← 用 lspci 确认实际 PCI 地址
      };
    };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
  };

  # ===== 笔记本电源管理 =====
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;          # powertop 自动调优（正确路径：powerManagement.powertop）
  };

  # TLP 电源管理
  services = {
    xserver.videoDrivers = [ "nvidia" ];
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
  # ===== 硬件工具 =====
  environment.systemPackages = with pkgs; [  
    nvidia-vaapi-driver
    libva-utils
    vdpauinfo

    # 硬件信息
    lshw
    hwinfo
    dmidecode
    pciutils
    usbutils

    # 电源/温度
    powertop
    tlp
    smartmontools
  ];

  # ===== 硬件断言 =====
  assertions = [
    {
      assertion = config.hardware.nvidia.modesetting.enable;
      message = "NVIDIA modesetting 必须启用，否则 Wayland/niri 无法使用 NVIDIA GPU";
    }
  ];
}
