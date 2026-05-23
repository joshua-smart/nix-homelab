{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gitea;
in
{
  services.gitea = {
    enable = true;
    settings = {
      server = {
        HTTP_PORT = 8087;
        ROOT_URL = "https://git.jsmart.dev";
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
    };
  };
  networking.services."git.jsmart.dev".port = cfg.settings.server.HTTP_PORT;

  sops.secrets."restic/repository_password" = { };
  services.restic.backups =
    lib.mapAttrs
      (
        _: opts:
        opts
        // {
          backupPrepareCommand =
            let
              sqlite = lib.getExe pkgs.sqlite;
            in
            /* bash */ ''
              set -e
              systemctl stop gitea
              ${sqlite} ${cfg.stateDir}/data/gitea.db ".backup '${cfg.stateDir}/gitea_dump.db'"
            '';
          backupCleanupCommand = /* bash */ ''
            systemctl start gitea
          '';
          paths = [
            "${cfg.stateDir}/custom"
            "${cfg.stateDir}/data"
            "${cfg.stateDir}/repositories"
            "${cfg.stateDir}/log"
            "${cfg.stateDir}/gitea_dump.db"
          ];
          passwordFile = config.sops.secrets."restic/repository_password".path;
          initialize = true;
          pruneOpts = [
            "--keep-weekly 1"
            "--keep-monthly 3"
            "--keep-yearly 1"
          ];
        }
      )
      {
        "gitea-local" = {
          repository = "/bulk/backup";
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-* 00:00:00";
            AccuracySec = "1h";
          };
        };
        "gitea-remote" = {
          repository = "sftp:restic-server@falen:gitea";
          timerConfig = {
            Persistent = true;
            OnCalendar = "*-*-* 01:00:00";
            AccuracySec = "1h";
          };
        };
      };

}
