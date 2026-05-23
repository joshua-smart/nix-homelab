{ ... }:
{
  networking.services."paperless.jsmart.dev".port = 8084;

  services.paperless = {
    enable = true;
    port = 8084;
    settings = {
      PAPERLESS_URL = "https://paperless.jsmart.dev";
    };
  };
}
