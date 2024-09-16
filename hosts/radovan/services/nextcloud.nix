{ config, ... }:
{
  age.secrets."nextcloud-root-password" = {
    file = ../../../secrets/nextcloud-root-password.age;
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = true;
    hostName = "files.jsmart.dev";
    config.adminpassFile = config.age.secrets."nextcloud-root-password".path;
    https = true;
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    enableACME = true;
    forceSSL = true;
  };
}
