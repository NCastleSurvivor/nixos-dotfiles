{ config, pkgs, ... }:
{
  services.pulseaudio.enable =false;
  security.rtkit.enable = true;
# ===== PipeWire 音频栈 =====
  # 替代 PulseAudio，支持低延迟、蓝牙、视频捕获
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;          # PulseAudio 兼容接口
    jack.enable = true;           # JACK 兼容接口
    wireplumber.enable = true;    # 会话管理器
  };

  # 音频质量优化
  services.pipewire.extraConfig.pipewire = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 32;
    };
  };

  # 音频工具
  environment.systemPackages = with pkgs; [
    alsa-utils       # ALSA 底层工具（alsamixer, amixer）
    pavucontrol      # PulseAudio 音量控制面板（兼容 PipeWire）
    qpwgraph         # PipeWire 图形化连线调音台
    playerctl        # MPRIS 媒体控制
    pamixer          # 命令行音量控制（waybar 模块用）
  ];
}
