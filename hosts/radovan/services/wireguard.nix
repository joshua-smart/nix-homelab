{ config, ... }:
{
  age.secrets."wireguard-private-key" = {
    file = ../../../secrets/wireguard-private-key.age;
    owner = "root";
    group = "systemd-network";
    mode = "640";
  };

  services.wireguard = {
    enable = true;
    privateKeyFile = config.age.secrets."wireguard-private-key".path;
    endpoint = "vpn.jsmart.dev";
    port = 51820;
    peers = [
      {
        # js@mobile
        publicKey = "QT+jxxR0T7zLTluyZo4oA0Ons1mk1MMz1jELB0I7EAE=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
      {
        # js@laptop
        publicKey = "bJpHqeuv49iVNj7jJPLdOIaUyNEHwr+IPZtbcRLyaDU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };
}
