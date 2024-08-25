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

  users = {
    users.admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg js@desktop"
      ];
    };
  };
}
