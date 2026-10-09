{
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  systemd.user.services = {
    xwayland-satellite = {
      description = "Xwayland outside your Wayland compositor.";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.xwayland-satellite} :1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;

        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };

}
