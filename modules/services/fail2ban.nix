{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.fail2ban.enable {

    services.fail2ban = {
      ignoreIP = [ "192.168.0.0/16" ];
    };
  };
}
