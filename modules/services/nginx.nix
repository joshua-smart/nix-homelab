{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    types
    optionalAttrs
    ;
  cfg = config.services.nginx;

  proxyHostOption = types.submodule {
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
      websockets = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Websocket support.
        '';
      };
      tailscale = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to restrict this server to tailscale clients only.
        '';
      };
    };
  };
in
{
  options.services.nginx = {
    proxyHosts = mkOption {
      type = types.attrsOf proxyHostOption;
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
      default = { };
    };
    tailscaleAddresses = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {

    age.secrets."cloudflare-ddns-token".file = ../../secrets/cloudflare-ddns-token.age;

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "josh@thesmarts.co.uk";

      certs."jsmart.dev" = {
        domain = "jsmart.dev";
        extraDomainNames = [ "*.jsmart.dev" ];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        credentialFiles.CLOUDFLARE_DNS_API_TOKEN_FILE = config.age.secrets."cloudflare-ddns-token".path;
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];

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
          {
            port,
            ssl,
            websockets,
            tailscale,
          }:
          (
            {
              locations."/" = {
                proxyPass = "http://127.0.0.1:${toString port}";
                proxyWebsockets = websockets;
              };
            }
            // optionalAttrs ssl {
              useACMEHost = "jsmart.dev";
              forceSSL = true;
            }
            // optionalAttrs tailscale {
              listenAddresses = cfg.tailscaleAddresses;
            }
          )
        ) cfg.proxyHosts;
    };
  };
}
