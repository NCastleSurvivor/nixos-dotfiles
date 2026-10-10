{
  description = "NCastleSurvivor — Lix + NixOS 26.05 + niri + Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      #inputs.nixpkgs.follows = "nixpkgs";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
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
      home-manager,
      nix-cachyos-kernel,
      sops-nix,
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
            # 配置文件在仓库根目录
            ./configuration.nix
            sops-nix.nixosModules.sops
            # Home Manager 作为 NixOS 模块
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix
            {
              # CachyOS 内核 overlay（提供 pkgs.cachyosKernels.linuxPackages-cachyos-*）
              # 使用 pinned overlay 确保二进制缓存命中（与 release 分支匹配）
              nixpkgs.overlays = [
                inputs.nix-cachyos-kernel.overlays.pinned
              ];

              home-manager = {
                extraSpecialArgs = { inherit inputs configsDir; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.zero = import ./home/zero/default.nix;
              };
            }
          ];
        };
      };

      # 格式化工具
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
