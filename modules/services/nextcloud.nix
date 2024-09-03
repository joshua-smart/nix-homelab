{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.services.nextcloud;
in
{
  config = mkIf cfg.enable {
    age.secrets."nextcloud-root-password" = {
      file = ../../secrets/nextcloud-root-password.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
    services.nextcloud = {
      hostName = "files.jsmart.dev";
      config.adminpassFile = config.age.secrets."nextcloud-root-password".path;
      https = true;
    };

    services.nginx.virtualHosts.${cfg.hostName} = {
      enableACME = true;
      forceSSL = true;
    };
  };
}
