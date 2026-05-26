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

  sops.secrets."restic/repository_password".owner = "restic";
  services.restic.secure_backups =
    lib.mapAttrs
      (
        _: opts:
        opts
        // {
          paths = [
            "${cfg.stateDir}/custom"
            "${cfg.stateDir}/data"
            "${cfg.stateDir}/repositories"
            "${cfg.stateDir}/log"
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
          repository = "/bulk/backup/gitea";
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
  systemd.services."restic-backups-gitea-local" = {
    conflicts = [ "gitea.service" ];
    after = [ "gitea.service" ];
    onSuccess = [ "gitea.service" ];
    onFailure = [ "gitea.service" ];
  };
  systemd.services."restic-backups-gitea-remote" = {
    conflicts = [ "gitea.service" ];
    after = [ "gitea.service" ];
    onSuccess = [ "gitea.service" ];
    onFailure = [ "gitea.service" ];
  };

}
