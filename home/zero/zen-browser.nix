{ inputs, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    inputs.stylix.homeModules.stylix
  ];
  stylix = {
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
      SearchEngines_Default = "Bing";
    };
    profiles.default = {
      isDefault = true;
    };
  };
}
