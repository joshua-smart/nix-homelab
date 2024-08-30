{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.services.adguardhome;
in
{
  config = mkIf cfg.enable {
    # Open ports for DNS server
    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    services.adguardhome = {
      openFirewall = true;
      port = 3000;
      host = "0.0.0.0";
      allowDHCP = true;
    };

    services.nginx.proxyHosts."adguard.home" = {
      port = cfg.port;
      ssl = false;
    };
  };
}
