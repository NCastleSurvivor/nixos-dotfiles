{ inputs, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    inputs.stylix.homeModules.stylix
  ];
  stylix = {
    enable = true;
    image = ../../../assets/wallpapers/wall.jpg;
    polarity = "dark";
    targets = {
      zen-browser.profileNames = [ "default" ];
      nixos-icons.enable = false;
    };
  };
  programs.zen-browser = {
    enable = true;
    languagePacks = [ "zh-CN" ];
    # suppressXdgMigrationWarning = true;
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      RequestedLocales = [ "zh-CN" ];
      # Firefox 企业策略的默认搜索引擎是对象，不是带下划线的扁平键。
      SearchEngines = {
        Default = "Bing";
      };
    };
    profiles.default = {
      isDefault = true;
    };
  };
}
