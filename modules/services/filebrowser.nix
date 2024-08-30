# Update to module when https://github.com/NixOS/nixpkgs/pull/289750 merges

{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in
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

    services.nginx.proxyHosts."files.jsmart.dev" = {
      port = 8080;
    };
  };
}
