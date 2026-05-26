{
  pkgs,
  lib,
  utils,
  config,
  ...
}:
let
  inherit (utils.systemdUtils.unitOptions) unitOption;
in
{
  options.services.restic.secure_backups = lib.mkOption {
    description = ''
      Periodic backups to create with Restic.

      Runs backup as the restic user with file read capabilities
    '';
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            passwordFile = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            environmentFile = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            rcloneOptions = lib.mkOption {
              type =
                with lib.types;
                nullOr (
                  attrsOf (oneOf [
                    str
                    bool
                  ])
                );
              default = null;
            };

            rcloneConfig = lib.mkOption {
              type =
                with lib.types;
                nullOr (
                  attrsOf (oneOf [
                    str
                    bool
                  ])
                );
              default = null;
            };

            rcloneConfigFile = lib.mkOption {
              type = with lib.types; nullOr path;
              default = null;
            };

            inhibitsSleep = lib.mkOption {
              default = false;
              type = lib.types.bool;
              example = true;
            };

            repository = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            repositoryFile = lib.mkOption {
              type = with lib.types; nullOr path;
              default = null;
            };

            paths = lib.mkOption {
              # This is nullable for legacy reasons only. We should consider making it a pure listOf
              # after some time has passed since this comment was added.
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              default = [ ];
            };

            command = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            exclude = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            timerConfig = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf unitOption);
              default = {
                OnCalendar = "daily";
                Persistent = true;
              };
            };

            extraBackupArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            extraOptions = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            initialize = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };

            pruneOpts = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            runCheck = lib.mkOption {
              type = lib.types.bool;
              default = builtins.length config.services.restic.secure_backups.${name}.checkOpts > 0;
              defaultText = lib.literalExpression "builtins.length config.services.secure_backups.${name}.checkOpts > 0";
            };

            checkOpts = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            dynamicFilesFrom = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            backupPrepareCommand = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            backupCleanupCommand = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
            };

            createWrapper = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };

            progressFps = lib.mkOption {
              type = with lib.types; nullOr numbers.nonnegative;
              default = null;
            };
          };
        }
      )
    );
    default = { };
  };

  config = lib.mkIf (config.services.restic.secure_backups != { }) {

    users.groups.restic = { };
    users.users.restic = {
      isSystemUser = true;
      group = "restic";
    };

    security.wrappers.restic = {
      source = lib.getExe pkgs.restic;
      owner = "restic";
      group = "restic";
      permissions = "u=rx,g=,o=";
      capabilities = "cap_dac_read_search+ep";
    };

    services.restic.backups = lib.mapAttrs (
      name: opts:
      opts
      // {
        user = "restic";
        package = pkgs.writeShellScriptBin "restic" ''
          exec ${config.security.wrapperDir}/restic "$@"
        '';
      }
    ) config.services.restic.secure_backups;
  };
}
