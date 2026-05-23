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
    "pdf.jsmart.dev".port = 8088;
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

  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_PORT = 8088;
    };
  };

  environment.systemPackages = with pkgs; [
    tmux
    ffmpeg
    python3
  ];
}
