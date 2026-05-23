{ config, ... }:
{
  age.secrets."cloudflare-ddns-token".file = ../../../secrets/cloudflare-ddns-token.age;
  services.ddclient = {
    enable = true;
    interval = "15min";
    domains = [
      "radovan.hosts.jsmart.dev"
      "jsmart.dev"
      "*.jsmart.dev"
    ];
    protocol = "cloudflare";
    username = "token";
    passwordFile = config.age.secrets."cloudflare-ddns-token".path;
    zone = "jsmart.dev";
  };
  systemd.services.ddclient.after = [ "nss-user-lookup.target" ];
}
