{ ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # ===== PipeWire 音频栈 =====
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true; # PulseAudio 兼容接口
    jack.enable = true; # JACK 兼容接口
    # wireplumber 默认跟随 pipewire.enable；无需显式再写 true。
  };

  # 音频质量/延迟参数
  services.pipewire.extraConfig.pipewire = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 32;
    };
  };
}
