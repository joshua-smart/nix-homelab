{ ... }:
{
  networking.services."portfolio.jsmart.dev".port = 8085;

  services.portfolio = {
    enable = true;
    port = 8085;
    host = "127.0.0.1";
  };
}
