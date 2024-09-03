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
      "minecraft"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN js@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg js@desktop"
    ];
  };

  age.secrets."gandi-api-key.env".file = ../../secrets/gandi-api-key.env.age;
  age.secrets."wireguard-private-key" = {
    file = ../../secrets/wireguard-private-key.age;
    owner = "root";
    group = "systemd-network";
    mode = "640";
  };
  age.secrets."restic-password".file = ../../secrets/restic-password.age;

  services = {
    nginx.enable = true;
    paperless.enable = true;
    gandi-dynamic-dns = {
      enable = true;
      domain = "jsmart.dev";
      record-name = "@";
      key-file = config.age.secrets."gandi-api-key.env".path;
      update-interval = "15m";
    };
    filebrowser.enable = true;
    nextcloud.enable = true;

    wireguard = {
      enable = true;
      privateKeyFile = config.age.secrets."wireguard-private-key".path;
      endpoint = "vpn.jsmart.dev";
      port = 51820;
      peers = [
        {
          # js@mobile
          publicKey = "QT+jxxR0T7zLTluyZo4oA0Ons1mk1MMz1jELB0I7EAE=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
        {
          # js@laptop
          publicKey = "IemeN9jqe87pg8m4Gbym8siARlg2mvE0i2pI3Z6GDCs=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
    adguardhome.enable = true;
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
        server-port = 25566;
      };
    };
  };

  services.restic.backups = {
    minecraft-server-season-5 = {
      paths = [ "${config.services.minecraft-servers.dataDir}/season-5" ];
      timerConfig = {
        OnCalendar = "*-*-* 12:00:00";
        Persistent = true;
      };
      initialize = true;
      repository = "/bulk/backup";
      passwordFile = config.age.secrets."restic-password".path;
      pruneOpts = [ "--keep-last 5" ];
    };
  };
}
