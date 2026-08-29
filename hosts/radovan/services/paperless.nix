{ config, ... }:
{
  networking.services."paperless.jsmart.dev".port = 8084;

  sops.secrets."paperless/env".owner = "paperless";

  services.paperless = {
    enable = true;
    port = 8084;
    settings = {
      PAPERLESS_URL = "https://paperless.jsmart.dev";
    };
    environmentFile = config.sops.secrets."paperless/env".path;
  };
}
