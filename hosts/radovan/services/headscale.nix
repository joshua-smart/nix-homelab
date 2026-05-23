{ ... }:
{
  networking.services."headscale.jsmart.dev" = {
    port = 8086;
    websockets = true;
  };

  age.secrets."headscale-auth-key".file = ../../../secrets/radovan-headscale-auth-key.age;
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8086;
    settings = {
      server_url = "https://headscale.jsmart.dev";
      dns = {
        nameservers.global = [ "1.1.1.1" ];
        base_domain = "tailnet.jsmart.dev";
        extra_records = [
          {
            name = "bitwarden.jsmart.dev";
            type = "A";
            value = "100.64.0.3";
          }
          {
            name = "bitwarden.jsmart.dev";
            type = "AAAA";
            value = "fd7a:115c:a1e0::3";
          }
          {
            name = "money.jsmart.dev";
            type = "A";
            value = "100.64.0.3";
          }
          {
            name = "money.jsmart.dev";
            type = "AAAA";
            value = "fd7a:115c:a1e0::3";
          }
        ];
      };
    };
  };
}
