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

      system-pkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ inputs.nix-minecraft.overlay ];
        };

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
        radovan = nixosSystem rec {
          system = "x86_64-linux";
          pkgs = system-pkgs system;
          modules = [
            ./hosts/radovan/configuration.nix
            agenix.nixosModules.default
          ];
          specialArgs = { inherit inputs; };
        };
        falen = nixosSystem rec {
          system = "aarch64-linux";
          pkgs = system-pkgs system;
          modules = [
            ./hosts/falen/configuration.nix
            agenix.nixosModules.default
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

      devShells."x86_64-linux".default =
        let
          pkgs = system-pkgs "x86_64-linux";
        in
        pkgs.mkShell {
          packages = [ pkgs.deploy-rs ];
        };
    };
}
