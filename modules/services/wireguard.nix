{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.wireguard;

  peerConfig = types.submodule {
    options = {
      publicKey = mkOption { type = types.str; };
      allowedIPs = mkOption {
        type = types.listOf types.str;
        example = [ "0.0.0.0/0" ];
      };
    };
  };

  wireguardPeers = builtins.map (peer: {
    wireguardPeerConfig = {
      PublicKey = peer.publicKey;
      AllowedIPs = peer.allowedIPs;
      Endpoint = "${cfg.endpoint}:${builtins.toString cfg.port}";
      PersistentKeepalive = 15;
    };
  }) cfg.peers;
in
{
  options.services.wireguard = {
    enable = mkEnableOption "wireguard service";
    port = mkOption {
      type = types.port;
      example = 51820;
    };
    endpoint = mkOption {
      type = types.str;
      example = "vpn.example.com";
    };
    privateKeyFile = mkOption { type = types.str; };
    peers = mkOption {
      type = types.listOf peerConfig;
      example = [
        {
          publicKey = "xxx";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };

  config = mkIf cfg.enable {

    # Public key: fzo3OXiMWLDbsu6siSOlU+fAFxb3Z+ChNai/skhnxHo=

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
            PrivateKeyFile = cfg.privateKeyFile;
            ListenPort = 51820;
          };
          inherit wireguardPeers;
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
