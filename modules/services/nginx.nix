{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    types
    optionalAttrs
    ;
  cfg = config.services.nginx;
in
{
  options.services.nginx.proxyHosts = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          port = mkOption {
            type = types.port;
            example = 8080;
          };
          ssl = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether to enable HTTPS support.
            '';
          };
        };
      }
    );
    description = ''
      List of hosts to proxy.
    '';
    example = {
      "example.com" = {
        port = 8080;
      };
      "subdomain.example.com" = {
        port = 3000;
        ssl = false;
      };
    };
  };

  config = mkIf cfg.enable {

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

      virtualHosts =
        {
          fallback = {
            default = true;
            rejectSSL = true;
          };
        }
        // builtins.mapAttrs (
          _:
          { port, ssl }:
          (
            {
              locations."/".proxyPass = "http://127.0.0.1:${toString port}";
            }
            // optionalAttrs ssl {
              enableACME = true;
              forceSSL = true;
            }
          )
        ) cfg.proxyHosts;
    };
  };
}
