{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }@inputs:
    {
      nixosConfigurations.home = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/home
          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.vhqkze = {
              imports = [ ./hosts/home/vhqkze.nix ];
            };
          }
          sops-nix.nixosModules.sops
        ];
        specialArgs = {
          inherit inputs;
          dockerDir = "/srv/docker";
        };
      };
      nixosConfigurations.router = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/router
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
