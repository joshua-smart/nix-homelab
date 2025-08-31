{ config, pkgs, ... }:
let
  proxyHosts = config.services.nginx.proxyHosts;
in
{
  imports = [
    ../../configuration-common.nix
    ./hardware-configuration.nix
    ./minecraft-servers.nix
  ];

  age.secrets = {
    "restic-password".file = ../../secrets/restic-password.age;
  };

  networking.hostName = "radovan";

  services.nginx = {
    enable = true;
    tailscaleAddresses = [
      "100.64.0.3"
      "[fd7a:115c:a1e0::3]"
    ];
    proxyHosts = {
      "money.jsmart.dev" = {
        port = 8081;
        tailscale = true;
      };
      "syncthing.jsmart.dev".port = 8082;
      "bitwarden.jsmart.dev" = {
        port = 8083;
        tailscale = true;
      };
      "paperless.jsmart.dev".port = 8084;
      "portfolio.jsmart.dev".port = 8085;
      "media.jsmart.dev".port = 8096;
      "headscale.jsmart.dev" = {
        port = 8086;
        websockets = true;
      };
    };
    virtualHosts.${config.services.nextcloud.hostName} = {
      enableACME = true;
      forceSSL = true;
    };
  };

  age.secrets."cloudflare-ddns-token".file = ../../secrets/cloudflare-ddns-token.age;
  services.ddclient = {
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

  services.actual = {
    enable = true;
    settings = {
      port = proxyHosts."money.jsmart.dev".port;
      hostname = "127.0.0.1";
    };
    openFirewall = false;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideFolders = false;
    overrideDevices = false;
    guiAddress = "127.0.0.1:${toString proxyHosts."syncthing.jsmart.dev".port}";
    settings.gui.insecureSkipHostcheck = true;
  };

  age.secrets."vaultwarden.env" = {
    file = ../../secrets/vaultwarden.env.age;
    owner = "vaultwarden";
  };
  services.vaultwarden = {
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
  services.restic.backups.vaultwarden = {
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

  services.paperless = {
    enable = true;
    port = proxyHosts."paperless.jsmart.dev".port;
  };

  services.portfolio = {
    enable = true;
    port = proxyHosts."portfolio.jsmart.dev".port;
    host = "127.0.0.1";
  };

  age.secrets."nextcloud-root-password" = {
    file = ../../secrets/nextcloud-root-password.age;
    owner = "nextcloud";
    group = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    hostName = "files.jsmart.dev";
    config = {
      dbtype = "sqlite";
      adminpassFile = config.age.secrets."nextcloud-root-password".path;
    };
    https = true;
    package = pkgs.nextcloud31;
    extraApps = {
      ncdownloader = pkgs.fetchNextcloudApp {
        sha256 = "sha256-cFu1Qey+gAESLTXTV76VhvT3VmtZhhqalx723ZTW62I=";
        url = "https://github.com/shiningw/ncdownloader/releases/download/v1.0.24/ncdownloader-release.tar.gz";
        license = "gpl3";
      };
    };
    extraAppsEnable = true;
  };

  services.jellyfin.enable = true;
  users.users.admin.extraGroups = [ "jellyfin" ];

  age.secrets."headscale-auth-key".file = ../../secrets/radovan-headscale-auth-key.age;
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = proxyHosts."headscale.jsmart.dev".port;
    settings = {
      server_url = "https://headscale.jsmart.dev";
      dns = {
        nameservers.global = [ "1.1.1.1" ];
        base_domain = "tailnet.jsmart.dev";
        extra_records = [
          {
            name = "bitwarden.jsmart.dev";
            type = "A";
            value = "100.64.0.3";
          }
          {
            name = "bitwarden.jsmart.dev";
            type = "AAAA";
            value = "fd7a:115c:a1e0::3";
          }
          {
            name = "money.jsmart.dev";
            type = "A";
            value = "100.64.0.3";
          }
          {
            name = "money.jsmart.dev";
            type = "AAAA";
            value = "fd7a:115c:a1e0::3";
          }
        ];
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--webclient" ];
    authKeyFile = config.age.secrets."headscale-auth-key".path;
  };

  services.prometheus = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 8088;
    exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
    ];
  };

  # services = {
  #   restic.backups = {
  #     paperless =
  #       let
  #         tmpdir = "/tmp/paperless-backup";
  #       in
  #       {
  #         backupPrepareCommand = # bash
  #           ''
  #             mkdir -p ${tmpdir}
  #             ${config.services.paperless.dataDir}/paperless-manage \
  #               document_exporter ${tmpdir} -d
  #           '';
  #         backupCleanupCommand = # bash
  #           ''
  #             rm -r ${tmpdir}
  #           '';
  #         paths = [ tmpdir ];
  #         timerConfig = {
  #           OnCalendar = "monthly";
  #           Persistent = true;
  #         };
  #         initialize = true;
  #         repository = "/bulk/backups/paperless";
  #         passwordFile = config.age.secrets."restic-password".path;
  #         pruneOpts = [ "--keep-last 3" ];
  #       };
  #   };
  # };

  environment.systemPackages = with pkgs; [
    tmux
    ffmpeg
    python3
  ];
}
