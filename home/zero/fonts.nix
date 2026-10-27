# Home Manager 字体
{ lib, ... }:
{
  # Home Manager 只声明 fonts.fontconfig.*；把 mkForce 放在叶子 defaultFonts 上，
  # 避免对 option-set 使用 mkForce。
  fonts.fontconfig = {
    enable = true;
    defaultFonts = lib.mkForce {
      sansSerif = [
        "Sarasa Gothic SC"
      ];
      monospace = [
        "Maple Mono NF CN"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
