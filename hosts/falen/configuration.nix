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

    };
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

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    port = 80;
  };

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
