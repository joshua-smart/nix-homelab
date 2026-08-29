{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = (lib.filesystem.listFilesRecursive ./services) ++ [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "radovan";

  sops.defaultSopsFile = ./secrets.yaml;

  # services.nginx = {
  #   tailscaleAddresses = [
  #     "100.64.0.3"
  #     "[fd7a:115c:a1e0::3]"
  #   ];
  # };

  networking.services = {
    "media.jsmart.dev".port = 8096;
    "headscale.jsmart.dev" = {
      port = 8086;
      websockets = true;
    };
  };

  services.jellyfin.enable = true;
  users.users.admin.extraGroups = [ "jellyfin" ];

  sops.secrets."headscale/auth_key" = { };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--webclient" ];
    authKeyFile = config.sops.secrets."headscale/auth_key".path;
  };

  environment.systemPackages = with pkgs; [
    tmux
    ffmpeg
    python3
  ];
}
