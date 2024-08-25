{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.services.fail2ban.enable {

  };
}
