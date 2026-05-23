{ config, pkgs, ... }:
{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  # Free up to 1GiB whenever there is less than 100MiB left.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';

  age.secrets = {
    "cloudflare-ddns-token".file = ../../secrets/cloudflare-ddns-token.age;
    "headscale-auth-key".file = ../../secrets/falen-headscale-auth-key.age;
  };

  networking.hostName = "falen";

  services.ddclient = {
    enable = true;
    interval = "15min";
    domains = [
      "falen.hosts.jsmart.dev"
    ];
    protocol = "cloudflare";
    passwordFile = config.age.secrets."cloudflare-ddns-token".path;
    zone = "jsmart.dev";
    usev6 = "";
    username = "token";
  };

  services.tailscale = {
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

  services.uptime-kuma = {
    enable = true;
    settings = {
      UPTIME_KUMA_HOST = "0.0.0.0";
      UPTIME_KUMA_PORT = "8080";
    };
  };
  networking.firewall.allowedTCPPorts = [
    8080
  ];

  fileSystems."/srv/backup".device = "/dev/disk/by-uuid/2d4061df-f8bb-4c3a-bc46-ca5f21af1d58";

  users.users.restic-server = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMhCO+XkG8FgUscAIw3O7TsRtkjmkXyEqTWbM09gqJ4v root@radovan"
    ];
    home = "/srv/backup";
    createHome = true;
    isSystemUser = true;
    group = "restic-server";
    shell = pkgs.bashInteractive;
  };
  users.groups.restic-server = { };
}
