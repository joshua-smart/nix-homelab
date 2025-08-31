{ config, ... }:
{
  imports = [
    ../../configuration-common.nix
    ./hardware-configuration.nix
  ];

  # Free up to 1GiB whenever there is less than 100MiB left.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';

  age.secrets = {
    "26t-network.env".file = ../../secrets/26t-network.env.age;
    "cloudflare-ddns-token".file = ../../secrets/cloudflare-ddns-token.age;
    "headscale-auth-key".file = ../../secrets/falen-headscale-auth-key.age;
  };

  networking = {
    hostName = "falen";
    wireless = {
      enable = true;
      secretsFile = config.age.secrets."26t-network.env".path;
      networks."26t".pskRaw = "ext:psk_home";
      interfaces = [ "wlp1s0u1u1" ];
    };
    firewall.allowedTCPPorts = [ 8080 ];
  };

  services = {
    # Dynamic DNS
    ddclient = {
      enable = true;
      interval = "15min";
      domains = [
        "falen.hosts.jsmart.dev"
      ];
      protocol = "cloudflare";
      passwordFile = config.age.secrets."cloudflare-ddns-token".path;
      zone = "jsmart.dev";
      usev6 = "";
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      authKeyFile = config.age.secrets."headscale-auth-key".path;
      extraUpFlags = [
        "--login-server"
        "https://headscale.jsmart.dev"
        "--advertise-exit-node"
        "--operator=js"
      ];
    };
  };
}
