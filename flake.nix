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
      nix-minecraft,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      pkgs = import nixpkgs {
        overlays = [ nix-minecraft.overlay ];
        inherit system;
        config.allowUnfree = true;
      };

      myNixosSystem =
        host:
        lib.nixosSystem {
          inherit pkgs system;
          modules = [
            ./hosts/${host}/configuration.nix
            agenix.nixosModules.default
            nix-minecraft.nixosModules.minecraft-servers
          ];
          specialArgs = {
            inherit host;
          };
        };
    in
    {
      nixosConfigurations = {
        server = myNixosSystem "server";
      };

      deploy.nodes.server = {
        hostname = "jsmart.dev";
        sshUser = "admin";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.server;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
