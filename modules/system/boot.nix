{ config, pkgs, lib, ... }:
{
  boot= {
    loader = {
      limine = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        extraConfig = ''
          TIMEOUT=5
          GRAPHICS=auto
          VERBOSE=no
        '';
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=auto"
      "nowatchdog"

      # NVIDIA DRM modesetting（Wayland 必需）
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
      "module_blacklist=nouveau"
      "nouveau.modeset=0"
      # AMD GPU 修复
      "amdgpu.sg_display=0"

      # CachyOS 内核优化
      "mitigations=off"          # 关闭 CPU 安全缓解，提升性能（桌面可接受风险）
      #"processor.max_cstate=1"   # 限制 C-state，降低延迟
      #"idle=nomwait"              # 禁用 mwait，部分系统可提升响应
    ];

    initrd.availableKernelModules = [
      "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"
      "xfs" "ntfs3" "vfat"
    ];
    blacklistedKernelModules = [ "ucsi_ccg" ];
    supportedFilesystems = [
      "xfs"     # 根分区和 home 分区
      "ntfs"    # NTFS（移动硬盘、Windows 磁盘）
      "vfat"    # EFI 分区
      "ext4"    # 兼容
      "btrfs"   # 兼容
    ];

    kernelModules = [ "kvm-amd" "iwlwifi" "iwlmvm" "ntfs3" ];
  };
}
