{ 
  pkgs, 
  ... 
}:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
            rime-moegirl
            rime-zhwiki
          ];
        })

      ];
      waylandFrontend = true;
    };
  };
  # 输入法工具
  environment.systemPackages = with pkgs; [
    qt6Packages.fcitx5-configtool   # 图形配置工具
  ];

}
