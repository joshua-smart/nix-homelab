{ config, lib, ... }:
{
  networking.services."bitwarden.jsmart.dev" = {
    port = 8083;
    tailscale = true;
  };

  age.secrets."vaultwarden.env" = {
    file = ../../../secrets/vaultwarden.env.age;
    owner = "vaultwarden";
  };
  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets."vaultwarden.env".path;
    config = {
      DOMAIN = "https://bitwarden.jsmart.dev";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8083;
    };
    backupDir = "/var/backup/vaultwarden";
  };

  services.restic.backups =
    lib.mapAttrs
      (
        _: opts:
        opts
        // {
          paths = [ config.services.vaultwarden.backupDir ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
            AccuracySec = "1h";
          };
          passwordFile = config.age.secrets."restic-password".path;
          pruneOpts = [
            "--keep-weekly 1"
            "--keep-monthly 3"
            "--keep-yearly 1"
          ];
          initialize = true;
        }
      )
      {
        "vaultwarden-local".repository = "/bulk/backup";
        "vaultwarden-remote".repository = "sftp:restic-server@falen:vaultwarden";
      };
}
