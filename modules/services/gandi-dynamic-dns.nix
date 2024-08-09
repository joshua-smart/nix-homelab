{ config, lib, ... }:
with lib;
let
  cfg = config.services.gandi-dynamic-dns;
in
{
  options.services.gandi-dynamic-dns = {
    enable = mkEnableOption "gandi-dynamic-dns";
    domain = mkOption { type = types.str; };
    record-name = mkOption { type = types.str; };
    update-interval = mkOption { type = types.str; };
    key-file = mkOption {
      type = types.path;
      description = ''
        Path to a file containing the GANDI_API_KEY environment variable.
      '';
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers = {
      gandi-dynamic-dns = {
        image = "adamvig/gandi-dynamic-dns";
        environment = {
          DOMAIN = cfg.domain;
          RECORD_NAME = cfg.record-name;
          UPDATE_INTERVAL = cfg.update-interval;
        };
        environmentFiles = [ cfg.key-file ];
      };
    };
  };
}
