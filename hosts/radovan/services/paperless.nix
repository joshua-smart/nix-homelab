{ config, ... }:
{
  services.paperless.enable = true;

  services.nginx.proxyHosts."paperless.jsmart.dev".port = config.services.paperless.port;
}
