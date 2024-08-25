{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.remote.enable = mkEnableOption "remote profile";

  config = mkIf config.profiles.remote.enable {

    nix.settings.trusted-users = [ "@wheel" ];
    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
    services.openssh.enable = true;
  };
}
