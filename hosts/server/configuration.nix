{ config, host, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  profiles = {
    boot.enable = true;
    localisation.enable = true;
    remote.enable = true;
  };

  networking.hostName = host;

  users.users.js = {
    uid = 1000;
    isNormalUser = true;
    description = "Joshua Smart";
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  age.secrets."gandi-api-key.env".file = ../../secrets/gandi-api-key.env.age;

  services = {
    paperless = {
      enable = true;
      address = "0.0.0.0";
    };
    gandi-dynamic-dns = {
      enable = true;
      domain = "jsmart.dev";
      record-name = "@";
      key-file = config.age.secrets."gandi-api-key.env".path;
      update-interval = "15m";
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

      nginx-proxy-manager = {
        image = "jc21/nginx-proxy-manager";
        ports = [
          "80:80"
          "443:443"
        ];
        volumes = [
          "/home/js/containers/nginx-proxy-manager/data:/data"
          "/home/js/containers/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
        ];
        extraOptions = [ "--network=proxy" ];
      };

      static-file-server = {
        image = "halverneus/static-file-server";
        volumes = [ "/home/js/containers/static-file-server:/web" ];
        extraOptions = [ "--network=proxy" ];
      };
    };
  };
}
