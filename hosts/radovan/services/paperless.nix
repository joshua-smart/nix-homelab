{ config, ... }:
let
  tmpdir = "/tmp/paperless-backup";
in
{
  services.paperless.enable = true;

  services.nginx.proxyHosts."paperless.jsmart.dev".port = config.services.paperless.port;

  age.secrets."restic-password".file = ../../../secrets/restic-password.age;

  services.restic.backups = {
    paperless = {
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
}
