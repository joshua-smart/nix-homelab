{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.openssh.enable {
    services.openssh = {
      settings = {
        PasswordAuthentication = false;
      };
    };
    # Setup for sshd by default
    services.fail2ban.enable = true;
  };
}
