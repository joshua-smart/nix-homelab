# Update to module when https://github.com/NixOS/nixpkgs/pull/289750 merges

{ config, lib, ... }:
with lib;
{
  options.services.filebrowser.enable = mkEnableOption "filebrowser service";

  config = mkIf config.services.filebrowser.enable {
    virtualisation.oci-containers.containers.filebrowser = {
      image = "filebrowser/filebrowser";
      volumes = [
        "/home/js/containers/filebrowser/root:/srv"
        "/home/js/containers/filebrowser/filebrowser.db:/database.db"
        "/home/js/containers/filebrowser/.filebrowser.json:/.filebrowser.json"
      ];
      ports = [ "8080:80" ];
    };
    services.nginx.enable = true;
    services.nginx.virtualHosts."files.jsmart.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
      };
    };
  };
}
