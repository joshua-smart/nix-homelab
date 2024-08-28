{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.profiles.user;
in
{
  options.profiles.user = {
    enable = mkEnableOption "user profile";
    defaultUser = mkOption {
      type = types.str;
      default = "admin";
    };
    groups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "docker" ];
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.defaultUser} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ] ++ cfg.groups;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg js@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN js@laptop"
      ];
    };
  };
}
