{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

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

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      deploy-rs,
      nixos-hardware,
      ...
    }@inputs:
    let
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg js@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN js@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK97cNMS1YQ08Q3Lam4RRzs0aQ4Lp1v+eoJGAKhRArFg"
      ];

      inherit (nixpkgs.lib) nixosSystem filesystem;

      system-pkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.nix-minecraft.overlay
            (final: prev: {
              myPackages = filesystem.packagesFromDirectoryRecursive {
                callPackage = final.callPackage;
                directory = ./pkgs;
              };
            })
          ];
        };

      deployLib =
        system:
        (import nixpkgs {
          inherit system;
          overlays = [
            deploy-rs.overlays.default
            (self: super: {
              deploy-rs = {
                inherit (system-pkgs system) deploy-rs;
                lib = super.deploy-rs.lib;
              };
            })
          ];
        }).deploy-rs.lib;
    in
    {
      nixosConfigurations = {
        radovan = nixosSystem rec {
          system = "x86_64-linux";
          pkgs = system-pkgs system;
          modules = [
            ./modules
            ./hosts/radovan/configuration.nix
            agenix.nixosModules.default
          ];
          specialArgs = { inherit inputs authorizedKeys; };
        };
        falen = nixosSystem rec {
          system = "aarch64-linux";
          pkgs = system-pkgs system;
          modules = [
            ./modules
            ./hosts/falen/configuration.nix
            agenix.nixosModules.default
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
          specialArgs = { inherit inputs authorizedKeys; };
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
          hostname = "192.168.1.2";
          sshUser = "admin";
          profiles.system = {
            user = "root";
            path = (deployLib "aarch64-linux").activate.nixos self.nixosConfigurations.falen;
          };
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

      devShells."x86_64-linux".default =
        let
          pkgs = system-pkgs "x86_64-linux";
        in
        pkgs.mkShell {
          packages = [
            pkgs.deploy-rs
            agenix.packages."x86_64-linux".agenix
          ];
        };
    };
}
