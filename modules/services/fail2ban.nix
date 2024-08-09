{ config, lib, ... }:
with lib;
{
  config = mkIf config.services.fail2ban.enable {

  };
}
