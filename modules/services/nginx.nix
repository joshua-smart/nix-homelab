{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.nginx.enable {

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };

    security.acme = {
      defaults.email = "josh@thesmarts.co.uk";
      acceptTerms = true;
    };

    services.nginx = {
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
  };
}
