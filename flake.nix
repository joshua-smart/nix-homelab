{
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

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
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
    }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem;

      deployLib =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        (import nixpkgs {
          inherit system;
          overlays = [
            deploy-rs.overlay
            (self: super: {
              deploy-rs = {
                inherit (pkgs) deploy-rs;
                lib = super.deploy-rs.lib;
              };
            })
          ];
        }).deploy-rs.lib;
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
            inherit (inputs) nix-minecraft;
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
            path = (deployLib "x86_64-linux").activate.nixos self.nixosConfigurations.radovan;
          };
        };
        falen = {
          hostname = "falen.hosts.jsmart.dev";
          sshUser = "admin";
          profiles.system = {
            user = "root";
            path = (deployLib "aarch64-linux").activate.nixos self.nixosConfigurations.falen;
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
