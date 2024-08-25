{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.adguardhome.enable {
    # Open ports for DNS server
    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      port = 80;
    };
  };
}
