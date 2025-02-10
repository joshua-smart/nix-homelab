{ config, ... }:
let
  cfg = config.services.vaultwarden;
  backupDir = "/tmp/vaultwarden-backup";
in
{
  age.secrets = {
    "vaultwarden.env" = {
      file = ../../../secrets/vaultwarden.env.age;
      owner = "vaultwarden";
    };
    "restic-password".file = ../../../secrets/restic-password.age;
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets."vaultwarden.env".path;
    config = {
      DOMAIN = "https://bitwarden.jsmart.dev";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
    inherit backupDir;
  };

  services.nginx.proxyHosts."bitwarden.jsmart.dev" = {
    port = cfg.config.ROCKET_PORT;
    websockets = true;
  };

  services.restic.backups = {
    vaultwarden = {
      paths = [ backupDir ];
      timerConfig = {
        OnCalendar = "monthly";
        Persistent = true;
      };
      initialize = true;
      repository = "/bulk/backups/vaultwarden";
      passwordFile = config.age.secrets."restic-password".path;
      pruneOpts = [ "--keep-last 3" ];
    };
    # vaultwarden-falen = {
    #   paths = [ backupDir ];
    #   timerConfig = {
    #     OnCalendar = "monthly";
    #     Persistent = true;
    #   };
    #   initialize = true;
    #   repository = "";
    # };
  };
}
