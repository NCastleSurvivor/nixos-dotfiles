{ pkgs, ... }:
{
  # ===== greetd + tuigreet 登录管理器 =====
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd ${pkgs.niri}/bin/niri-session";
    };
  };

  environment.systemPackages = [ pkgs.tuigreet ];
}
