{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      sops-nix,
      zen-browser,
      vicinae,
      apple-fonts,
      ...
    }@inputs:
    {
      nixosConfigurations.home = nixpkgs.lib.nixosSystem {
        modules = [
          ./home/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.vhqkze = {
              imports = [
                inputs.vicinae.homeManagerModules.default
                ./home/vhqkze.nix
              ];
            };
            home-manager.extraSpecialArgs = {
              inherit
                zen-browser
                nixpkgs
                nixpkgs-unstable
                vicinae
                ; # 仅传递 zen-browser 和 nixpkgs
              # 如果 home.nix 中还需要其他 inputs，在这里添加
            };
            # home-manager.extraSpecialArgs = inputs;
            # home-manager.extraSpecialArgs = builtins.removeAttrs inputs [ "home-manager" ];
            # home-manager.users.orange = home-manager.lib.homeManagerConfiguration {
            #   # 使用 home-manager.lib.homeManagerConfiguration
            #   pkgs = nixpkgs.legacyPackages.aarch64-linux; # 或者您系统对应的架构
            #   extraSpecialArgs = inputs; # 将inputs正确传递给home.nix
            #   modules = [
            #     ./home.nix
            #     # zen-browser的homeModules.beta现在作为home-manager配置的一部分被导入
            #     # 它将在home.nix内部通过import处理
            #   ];
            # };
          }
          sops-nix.nixosModules.sops
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
