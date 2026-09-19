{ pkgs, inputs, ... }:
{
    imports = [
        inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
        enable = true;
        settings = {
            compositor = {
                name = "niri";
            };

            bar = {
                position = "top";
                height = 36;
                margin = {
                    top = 8;
                    left = 12;
                    right = 12;
                };
                transparent = true;

                modules = {
                    left = [
                        "workspaces"
                        "active-window"
                    ];
                    center = [
                        "clock"
                    ];
                    right = [
                        "tray"
                        "volume"
                        "network"
                        "battery"
                        "control-center-toggle"
                    ];
                };
            };

            workspaces = {
                showIcons = true;
                hideEmpty = false;
            };

            controlCenter = {
                position = "right";
                cards = [
                    "media-player"
                    "sliders"
                    "quick-toggles"
                ];
            };

            notifications = {
                enable = true;
                anchor = "top-right";
                timeout = 5000;
                maxCount = 5;
            };

            wallpaper = {
                enable = false;
                mode = "fill";
            };
            theme = {
                colorScheme = "dark";
                useWallpaperColors = "true";
            };
        };
    };
}
