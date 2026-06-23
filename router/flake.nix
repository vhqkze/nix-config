{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    {
      nixosConfigurations.router = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
