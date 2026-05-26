{ lib, config, ... }:
{

  networking.services."money.jsmart.dev" = {
    port = 8081;
    tailscale = true;
  };

  services.actual = {
    enable = true;
    settings = {
      port = 8081;
      hostname = "127.0.0.1";
    };
    openFirewall = false;
  };

  sops.secrets."restic/repository_password".owner = "restic";
  services.restic.secure_backups =
    lib.mapAttrs
      (
        _: opts:
        opts
        // {
          dynamicFilesFrom = /* bash */ ''
            readlink -m ${config.services.actual.settings.dataDir}
          '';
          passwordFile = config.sops.secrets."restic/repository_password".path;
          initialize = true;
          timerConfig = {
            Persistent = true;
            OnCalendar = "daily";
            AccuracySec = "1h";
          };
          pruneOpts = [
            "--keep-weekly 1"
            "--keep-monthly 3"
            "--keep-yearly 1"
          ];
        }
      )
      {
        "actual-local".repository = "/bulk/backup/actual";
        "actual-remote".repository = "sftp:restic-server@falen:actual";
      };
  systemd.services."restic-backups-actual-local" = {
    conflicts = [ "actual.service" ];
    after = [ "actual.service" ];
    onSuccess = [ "actual.service" ];
    onFailure = [ "actual.service" ];
  };
  systemd.services."restic-backups-actual-remote" = {
    conflicts = [ "actual.service" ];
    after = [ "actual.service" ];
    onSuccess = [ "actual.service" ];
    onFailure = [ "actual.service" ];
  };
}
