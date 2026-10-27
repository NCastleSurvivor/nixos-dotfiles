{
  config,
  ...
}:
{
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      modesetting.enable = true; # Wayland 必需
      # 纯 Wayland 会话不需要 nvidia-settings（它主要面向 Xorg）。
      nvidiaSettings = false;
      # RTX 2060 也可使用 NVIDIA 开源内核模块；当前保留 proprietary，
      # 以匹配现有的 PRIME offload + fine-grained power management 配置。
      open = false;

      powerManagement = {
        enable = true;
        finegrained = true; # 细粒度电源管理，需与 PRIME offload 搭配
      };

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:6:0:0"; # 用 lspci 确认实际 PCI 地址
        nvidiaBusId = "PCI:1:0:0"; # 用 lspci 确认实际 PCI 地址
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

  # ===== 硬件断言 =====
  assertions = [
    {
      assertion = config.hardware.nvidia.modesetting.enable;
      message = "NVIDIA modesetting 必须启用，否则 Wayland/niri 无法使用 NVIDIA GPU";
    }
  ];
}
