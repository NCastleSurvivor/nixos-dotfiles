{ 
  pkgs, 
  ... 
}:

{
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  systemd.user.services = {
    xwayland-satellite = {
      description = "Xwayland outside your Wayland compositor.";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

}

