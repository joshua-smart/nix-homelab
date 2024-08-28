{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # Free up to 1GiB whenever there is less than 100MiB left.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';

  profiles = {
    remote.enable = true;
    localisation.enable = true;
    user = {
      enable = true;
      groups = [ "docker" ];
    };
  };

  age.secrets."gandi-api-key.env".file = ../../secrets/gandi-api-key.env.age;

  services = {
    gandi-dynamic-dns = {
      enable = true;
      domain = "jsmart.dev";
      record-name = "falen.hosts";
      key-file = config.age.secrets."gandi-api-key.env".path;
      update-interval = "15m";
    };
    adguardhome.enable = true;
  };

  age.secrets."26t-network.env".file = ../../secrets/26t-network.env.age;

  networking = {
    hostName = "falen";
    wireless = {
      enable = true;
      environmentFile = config.age.secrets."26t-network.env".path;
      networks."26t".psk = "@PSK_26T@";
      interfaces = [ "wlp1s0u1u1" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    helix
  ];
}
