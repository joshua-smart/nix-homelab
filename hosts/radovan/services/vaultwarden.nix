{ config, ... }:
let
  cfg = config.services.vaultwarden;
in
{
  age.secrets."vaultwarden.env" = {
    file = ../../../secrets/vaultwarden.env.age;
    owner = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets."vaultwarden.env".path;
    config = {
      DOMAIN = "https://bitwarden.jsmart.dev";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
    backupDir = "/bulk/vaultwarden-backup";
  };

  services.nginx.proxyHosts."bitwarden.jsmart.dev" = {
    port = cfg.config.ROCKET_PORT;
    websockets = true;
  };
}
