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

    services.nginx.virtualHosts."vpn.jsmart.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
      };
    };

    virtualisation.oci-containers.containers = {

      wireguard = {
        image = "linuxserver/wireguard:latest";
        environment = {
          PUID = "1000";
          GUID = "1000";
          TZ = "Europe/London";
          SERVERURL = "vpn.jsmart.dev";
          SERVERPORT = "51820";
        };
        volumes = [ "/home/js/containers/wireguard/config:/config" ];
        ports = [ "51820:51820/udp" ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        ];
      };

      wireguard-ui = {
        image = "ngoduykhanh/wireguard-ui:latest";
        dependsOn = [ "wireguard" ];
        extraOptions = [ "--cap-add=NET_ADMIN" ];
        environment = {
          SESSION_SECRET = "wVIoDwTtfu27tJ5Of2i0MPcp";
          WGUI_USERNAME = "admin";
          WGUI_PASSWORD = "wC2SNnvp7AfvhMuYkYpBdbzxc";
          WGUI_MANAGE_START = "true";
          WGUI_MANAGE_RESTART = "true";
        };
        volumes = [
          "/home/js/containers/wireguard/config:/etc/wireguard"
          "/home/js/containers/wireguard/db:/app/db"
        ];
        ports = [ "5000:5000" ];
      };
    };

    # networking.firewall.allowedUDPPorts = [ 51820 ];
    # networking.useNetworkd = true;
    # systemd.network = {
    #   enable = true;
    #   netdevs = {
    #     "50-wg0" = {
    #       netdevConfig = {
    #         Kind = "wireguard";
    #         Name = "wg0";
    #         MTUBytes = "1300";
    #       };
    #       wireguardConfig = {
    #         PrivateKeyFile = config.age.secrets."wireguard-private-key".path;
    #         ListenPort = 51820;
    #       };
    #       wireguardPeers = [
    #         {
    #           wireguardPeerConfig = {
    #             PublicKey = "OAWXRKATYDG6k9uROASHEGCIle3KNVAMTMTnfbMDaR4=";
    #             AllowedIPs = [ "10.100.0.2" ];
    #           };
    #         }
    #       ];
    #     };
    #   };
    #   networks.wg0 = {
    #     matchConfig.Name = "wg0";
    #     address = [ "10.100.0.1/24" ];
    #     networkConfig = {
    #       IPMasquerade = "ipv4";
    #       IPForward = true;
    #     };
    #   };
    # };
  };
}
