{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      sops-nix,
      deploy-rs,
      nixos-hardware,
      ...
    }@inputs:
    let
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

      defaultModules = (filesystem.listFilesRecursive ./modules) ++ [
        sops-nix.nixosModules.sops
      ];
    in
    {
      nixosConfigurations = {
        radovan = nixosSystem rec {
          system = "x86_64-linux";
          pkgs = system-pkgs system;
          modules = defaultModules ++ [
            ./hosts/radovan/configuration.nix
            inputs.nix-minecraft.nixosModules.minecraft-servers
          ];
          specialArgs = { inherit inputs; };
        };
        falen = nixosSystem rec {
          system = "aarch64-linux";
          pkgs = system-pkgs system;
          modules = defaultModules ++ [
            ./hosts/falen/configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
          specialArgs = { inherit inputs; };
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
          hostname = "192.168.0.190";
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
          packages =
            (with pkgs; [
              ssh-to-age
              age
              sops
            ])
            ++ [
              pkgs.deploy-rs
            ];
        };
    };
}
