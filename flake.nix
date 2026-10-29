{
  description = "NCastleSurvivor — Lix + NixOS 26.05 baseline + niri + Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mark-shot = {
      url = "github:jswysnemc/mark-shot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      configsDir = ./configs;
    in
    {
      nixosConfigurations = {
        NCastleSurvivor = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs configsDir;
          };
          modules = [
            ./configuration.nix
            agenix.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix
            {
              # CachyOS 内核 overlay；pinned 版本用于命中二进制缓存。
              nixpkgs.overlays = [
                inputs.nix-cachyos-kernel.overlays.pinned
              ];

              home-manager = {
                extraSpecialArgs = { inherit inputs configsDir; };
                # 统一使用系统 nixpkgs，使 unfree predicate、overlay 和包版本一致。
                useGlobalPkgs = true;
                useUserPackages = true;
                users.zero = import ./home/zero/default.nix;
              };
            }
          ];
        };
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
