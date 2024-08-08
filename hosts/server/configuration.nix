# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, host, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ../../nixosModules
  ];

  networking.hostName = host;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  users.users.js = {
    uid = 1000;
    isNormalUser = true;
    description = "Joshua Smart";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "docker"
      "uinput"
    ];
    useDefaultShell = true;
  };

  nix.settings.trusted-users = [ "@wheel" ];
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services = {
    openssh.enable = true;
    paperless = {
      enable = true;
      address = "0.0.0.0";
    };
  };

  age.secrets."gandi-api-key.env".file = ../../secrets/gandi-api-key.env.age;

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

      gandi-dynamic-dns = {
        image = "adamvig/gandi-dynamic-dns";
        environment = {
          DOMAIN = "jsmart.dev";
          RECORD_NAME = "@";
          UPDATE_INTERVAL = "15m";
        };
        environmentFiles = [ config.age.secrets."gandi-api-key.env".path ];
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
