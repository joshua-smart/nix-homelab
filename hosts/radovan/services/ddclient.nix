{ config, ... }:
{
  sops.secrets."cloudflare/ddns_token" = { };
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
    passwordFile = config.sops.secrets."cloudflare/ddns_token".path;
    zone = "jsmart.dev";
  };
  systemd.services.ddclient.after = [ "nss-user-lookup.target" ];
}
