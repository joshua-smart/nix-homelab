{ ... }:
let
  port = 8081;
in
{
  services.actual = {
    enable = true;
    settings = {
      inherit port;
      hostname = "0.0.0.0";
    };
    openFirewall = true;
  };

  services.nginx.proxyHosts."money.jsmart.dev".port = port;
}
