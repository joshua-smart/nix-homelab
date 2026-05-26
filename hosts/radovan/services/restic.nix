{ config, pkgs, ... }:
{
  sops.secrets."restic/ssh_private_key" = {
    owner = "restic";
    mode = "400";
    path = "${config.users.users.restic.home}/.ssh/id_ed25519";
  };
  sops.secrets."restic/ssh_public_key" = {
    owner = "restic";
    mode = "444";
    path = "${config.users.users.restic.home}/.ssh/id_ed25519.pub";
  };

  users.users.restic = {
    home = "/var/lib/restic";
    createHome = true;
    shell = pkgs.bashInteractive;
  };
}
