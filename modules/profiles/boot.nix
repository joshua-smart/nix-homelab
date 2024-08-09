{ config, lib, ... }:
with lib;
{
  options.profiles.boot.enable = mkEnableOption "boot profile";

  config = mkIf config.profiles.boot.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
