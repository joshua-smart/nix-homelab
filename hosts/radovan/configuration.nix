{
  config,
  pkgs,
  nix-minecraft,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    nix-minecraft.nixosModules.minecraft-servers
  ];
  nixpkgs.overlays = [ nix-minecraft.overlay ];

  profiles = {
    localisation.enable = true;
    remote.enable = true;
    user = {
      enable = true;
      groups = [
        "docker"
        "minecraft"
      ];
    };
  };

  networking.hostName = "radovan";

  users.users.js = {
    isNormalUser = true;
    description = "Joshua Smart";
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN js@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg js@desktop"
    ];
  };

  age.secrets."gandi-api-key.env".file = ../../secrets/gandi-api-key.env.age;

  services = {
    paperless.enable = true;
    gandi-dynamic-dns = {
      enable = true;
      domain = "jsmart.dev";
      record-name = "@";
      key-file = config.age.secrets."gandi-api-key.env".path;
      update-interval = "15m";
    };
    filebrowser.enable = true;
    wireguard.enable = true;
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.season-5 = {
      enable = true;
      package = pkgs.minecraftServers.paper-1_21;
      jvmOpts = "-Xms4096M -Xmx8192M";
      serverProperties = {
        server-port = 25567;
      };
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      v5-minecraft = {
        image = "itzg/minecraft-server";
        ports = [ "25566:25565" ];
        environment = {
          EULA = "true";
          MEMORY = "4G";
          TYPE = "PAPER";
          VERSION = "1.21";
        };
        volumes = [ "/home/js/containers/v5-minecraft:/data" ];
      };

      v5-minecraft-backup = {
        image = "itzg/mc-backup";
        environment = {
          BACKUP_INTERVAL = "1d";
          INITIAL_DELAY = "0";
        };
        volumes = [
          "/home/js/containers/v5-minecraft:/data:ro"
          "/home/js/containers/v5-minecraft-backups:/backups"
        ];
        dependsOn = [ "v5-minecraft" ];
        extraOptions = [ "--network=container:v5-minecraft" ];
      };
    };
  };
}
