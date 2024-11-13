{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ./services
  ];

  profiles = {
    localisation.enable = true;
    remote.enable = true;
    user.enable = true;
  };

  networking.hostName = "radovan";

  age.secrets."gandi-api-key.env".file = ../../secrets/gandi-api-key.env.age;

  services = {
    nginx.enable = true;

    gandi-dynamic-dns = {
      enable = true;
      domain = "jsmart.dev";
      record-name = "@";
      key-file = config.age.secrets."gandi-api-key.env".path;
      update-interval = "15m";
    };
    # adguardhome.enable = true;
  };
}
