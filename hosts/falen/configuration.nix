{ config, ... }:
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
    user.enable = true;
  };

  age.secrets."26t-network.env".file = ../../secrets/26t-network.env.age;

  networking = {
    hostName = "falen";
    wireless = {
      enable = true;
      secretsFile = config.age.secrets."26t-network.env".path;
      networks."26t".psk = "ext:PSK_26T";
      interfaces = [ "wlp1s0u1u1" ];
    };
  };
}
