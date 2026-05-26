{ config, lib, ... }:
{
  networking.services."bitwarden.jsmart.dev" = {
    port = 8083;
    tailscale = true;
  };

  sops.secrets."vaultwarden/env" = {
    owner = "vaultwarden";
  };
  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.secrets."vaultwarden/env".path;
    config = {
      DOMAIN = "https://bitwarden.jsmart.dev";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8083;
    };
    backupDir = "/var/backup/vaultwarden";
  };

  sops.secrets."restic/repository_password".owner = "restic";
  services.restic.secure_backups =
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
          passwordFile = config.sops.secrets."restic/repository_password".path;
          pruneOpts = [
            "--keep-weekly 1"
            "--keep-monthly 3"
            "--keep-yearly 1"
          ];
          initialize = true;
        }
      )
      {
        "vaultwarden-local".repository = "/bulk/backup/vaultwarden";
        "vaultwarden-remote".repository = "sftp:restic-server@falen:vaultwarden";
      };
}
