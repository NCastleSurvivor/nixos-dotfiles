{ pkgs, ... }:
{
let
    main = "age197gfgj83z2z0hmt5negrzznnt8kcuhajjn66yr5ajtu5eswqeanqj4ndr0";
in
{
        environment.systemPackages = with pkgs; [
        age
        agenix-cli
        ];
    };
    }
