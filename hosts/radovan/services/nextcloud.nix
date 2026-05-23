{ config, pkgs, ... }:
{
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    enableACME = true;
    forceSSL = true;
  };

  age.secrets."nextcloud-root-password" = {
    file = ../../../secrets/nextcloud-root-password.age;
    owner = "nextcloud";
    group = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    hostName = "files.jsmart.dev";
    config = {
      dbtype = "sqlite";
      adminpassFile = config.age.secrets."nextcloud-root-password".path;
    };
    https = true;
    package = pkgs.nextcloud33;
    extraApps = {
      # ncdownloader = pkgs.fetchNextcloudApp {
      #   sha256 = "sha256-cFu1Qey+gAESLTXTV76VhvT3VmtZhhqalx723ZTW62I=";
      #   url = "https://github.com/shiningw/ncdownloader/releases/download/v1.0.24/ncdownloader-release.tar.gz";
      #   license = "gpl3";
      # };
    };
    extraAppsEnable = true;
  };
}
