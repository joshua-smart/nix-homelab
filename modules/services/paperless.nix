{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.services.paperless;
in
{
  config = mkIf cfg.enable {
    # Setup reverse proxy
    services.nginx.proxyHosts."paperless.jsmart.dev".port = cfg.port;
  };
}
