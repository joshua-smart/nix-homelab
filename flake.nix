{
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      deploy-rs,
      ...
    }:
    let
      inherit (nixpkgs.lib) nixosSystem;
    in
    {
      nixosConfigurations = {
        radovan = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/radovan/configuration.nix
            agenix.nixosModules.default
          ];
          specialArgs = {
            host = "radovan";
          };
        };
        falen = nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/falen/configuration.nix
            agenix.nixosModules.default
          ];
        };
      };

      deploy.nodes = {
        radovan = {
          hostname = "jsmart.dev";
          sshUser = "admin";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib."x86_64-linux".activate.nixos self.nixosConfigurations.radovan;
          };
        };
        falen = {
          hostname = "192.168.0.153";
          sshUser = "admin";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib."aarch64-linux".activate.nixos self.nixosConfigurations.falen;
          };
          remoteBuild = true;
        };
      };

      # host 'falen' is ommitted from checks as it cannot be build on x86_64-linux
      checks = builtins.mapAttrs (
        system: deployLib:
        deployLib.deployChecks {
          nodes = {
            inherit (self.deploy.nodes) radovan;
          };
        }
      ) deploy-rs.lib;
    };
}
