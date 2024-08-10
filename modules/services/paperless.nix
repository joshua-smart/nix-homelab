{ config, lib, ... }:
with lib;
{
  config = mkIf config.services.paperless.enable {
    # Setup reverse proxy
    services.nginx.enable = true;
    services.nginx.virtualHosts."paperless.jsmart.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:28981";
      };
    };
  };
}
