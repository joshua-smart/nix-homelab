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

  sops.secrets."restic/repository_password" = { };
  services.restic.backups =
    lib.mapAttrs
      (
        _: opts:
        opts
        // {
          backupPrepareCommand = /* bash */ ''
            systemctl stop actual
          '';
          backupCleanupCommand = /* bash */ ''
            systemctl start actual
          '';
          dynamicFilesFrom = /* bash */ ''
            readlink -f ${config.services.actual.settings.dataDir}
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
        "actual-local".repository = "/bulk/backup";
        "actual-remote".repository = "sftp:restic-server@falen:actual";
      };
}
