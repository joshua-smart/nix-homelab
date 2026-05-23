{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = (lib.filesystem.listFilesRecursive ./services) ++ [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  age.secrets = {
    "restic-password".file = ../../secrets/restic-password.age;
  };

  networking.hostName = "radovan";

  # services.nginx = {
  #   tailscaleAddresses = [
  #     "100.64.0.3"
  #     "[fd7a:115c:a1e0::3]"
  #   ];
  # };

  networking.services = {
    "media.jsmart.dev".port = 8096;
    "headscale.jsmart.dev" = {
      port = 8086;
      websockets = true;
    };
    "pdf.jsmart.dev".port = 8088;
  };

  services.jellyfin.enable = true;
  users.users.admin.extraGroups = [ "jellyfin" ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--webclient" ];
    authKeyFile = config.age.secrets."headscale-auth-key".path;
  };

  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_PORT = 8088;
    };
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
