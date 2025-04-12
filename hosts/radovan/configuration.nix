{ config, pkgs, ... }:
let
  proxyHosts = config.services.nginx.proxyHosts;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ./minecraft-servers.nix
  ];

  profiles = {
    localisation.enable = true;
    remote.enable = true;
    user = {
      enable = true;
      groups = [ ];
    };
  };

  networking.hostName = "radovan";

  age.secrets = {
    "cloudflare-ddns-token".file = ../../secrets/cloudflare-ddns-token.age;
    "vaultwarden.env" = {
      file = ../../secrets/vaultwarden.env.age;
      owner = "vaultwarden";
    };
    "restic-password".file = ../../secrets/restic-password.age;
    "nextcloud-root-password" = {
      file = ../../secrets/nextcloud-root-password.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  services = {
    nginx = {
      enable = true;
      proxyHosts = {
        "money.jsmart.dev".port = 8081;
        "syncthing.jsmart.dev".port = 8082;
        "bitwarden.jsmart.dev".port = 8083;
        "paperless.jsmart.dev".port = 8084;
        "jsmart.dev".port = 8085;
      };
      virtualHosts.${config.services.nextcloud.hostName} = {
        enableACME = true;
        forceSSL = true;
      };
    };

    # Dynamic DNS
    ddclient = {
      enable = true;
      interval = "15min";
      domains = [
        "radovan.hosts.jsmart.dev"
        "jsmart.dev"
        "*.jsmart.dev"
      ];
      protocol = "cloudflare";
      passwordFile = config.age.secrets."cloudflare-ddns-token".path;
      zone = "jsmart.dev";
    };

    actual = {
      enable = true;
      settings = {
        port = config.services.nginx.proxyHosts."money.jsmart.dev".port;
        hostname = "127.0.0.1";
      };
      openFirewall = false;
    };

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      overrideFolders = false;
      overrideDevices = false;
      guiAddress = "127.0.0.1:${toString proxyHosts."syncthing.jsmart.dev".port}";
      settings.gui.insecureSkipHostcheck = true;
    };

    vaultwarden = {
      enable = true;
      environmentFile = config.age.secrets."vaultwarden.env".path;
      config = {
        DOMAIN = "https://bitwarden.jsmart.dev";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = proxyHosts."bitwarden.jsmart.dev".port;
      };
      backupDir = "/var/backup/vaultwarden";
    };

    paperless = {
      enable = true;
      port = proxyHosts."paperless.jsmart.dev".port;
    };

    portfolio = {
      enable = true;
      port = proxyHosts."jsmart.dev".port;
      host = "127.0.0.1";
    };

    nextcloud = {
      enable = true;
      hostName = "files.jsmart.dev";
      config = {
        dbtype = "sqlite";
        adminpassFile = config.age.secrets."nextcloud-root-password".path;
      };
      https = true;
      package = pkgs.nextcloud31;
    };

    restic.backups = {
      vaultwarden = {
        paths = [ config.services.vaultwarden.backupDir ];
        timerConfig = {
          OnCalendar = "monthly";
          Persistent = true;
        };
        initialize = true;
        repository = "/bulk/backups/vaultwarden";
        passwordFile = config.age.secrets."restic-password".path;
        pruneOpts = [ "--keep-last 3" ];
      };

      paperless =
        let
          tmpdir = "/tmp/paperless-backup";
        in
        {
          backupPrepareCommand = # bash
            ''
              mkdir -p ${tmpdir}
              ${config.services.paperless.dataDir}/paperless-manage \
                document_exporter ${tmpdir} -d
            '';
          backupCleanupCommand = # bash
            ''
              rm -r ${tmpdir}
            '';
          paths = [ tmpdir ];
          timerConfig = {
            OnCalendar = "monthly";
            Persistent = true;
          };
          initialize = true;
          repository = "/bulk/backups/paperless";
          passwordFile = config.age.secrets."restic-password".path;
          pruneOpts = [ "--keep-last 3" ];
        };
    };

    # nginx.virtualHosts."happy-valentines-day.jsmart.dev" = {
    #   locations."/" = {
    #     root = "/var";
    #     index = "rish_val.png";
    #   };
    #   useACMEHost = "jsmart.dev";
    #   forceSSL = true;
    # };
  };

  environment.systemPackages = with pkgs; [ tmux ];
}
