{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.services.wireguard.enable = mkEnableOption "wireguard service";

  config = mkIf config.services.wireguard.enable {

    # Public key: fzo3OXiMWLDbsu6siSOlU+fAFxb3Z+ChNai/skhnxHo=

    age.secrets."wireguard-private-key" = {
      file = ../../secrets/wireguard-private-key.age;
      owner = "root";
      group = "systemd-network";
      mode = "640";
    };

    networking.firewall.allowedUDPPorts = [ 51820 ];
    networking.useNetworkd = true;
    systemd.network = {
      enable = true;
      netdevs = {
        "50-wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1300";
          };
          wireguardConfig = {
            PrivateKeyFile = config.age.secrets."wireguard-private-key".path;
            ListenPort = 51820;
          };
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                PublicKey = "QT+jxxR0T7zLTluyZo4oA0Ons1mk1MMz1jELB0I7EAE=";
                AllowedIPs = [
                  "0.0.0.0/0"
                  "::/0"
                ];
                Endpoint = "vpn.jsmart.dev:51820";
                PersistentKeepalive = 15;
              };
            }
          ];
        };
      };
      networks.wg0 = {
        matchConfig.Name = "wg0";
        address = [ "10.100.0.1/24" ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPForward = true;
        };
      };
    };
  };
}
