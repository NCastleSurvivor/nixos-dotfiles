{
  description = "NCastleSurvivor — Lix + NixOS 26.05 + niri + Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  };

  outputs = { self, nixpkgs, home-manager, nix-cachyos-kernel, ... }@inputs:
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
            # 配置文件在仓库根目录
            ./configuration.nix

            # Home Manager 作为 NixOS 模块
            home-manager.nixosModules.home-manager
            {
              # CachyOS 内核 overlay（提供 pkgs.cachyosKernels.linuxPackages-cachyos-*）
              # 使用 pinned overlay 确保二进制缓存命中（与 release 分支匹配）
              nixpkgs.overlays = [ 
                nix-cachyos-kernel.overlays.pinned
	      ];

	      home-manager.extraSpecialArgs = { inherit inputs configsDir; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zero = import ./home/zero/default.nix;
            }
          ];
        };
      };

      # 格式化工具
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
