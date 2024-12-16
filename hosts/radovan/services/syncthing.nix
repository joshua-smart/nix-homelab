{ ... }:
let
  guiPort = 8384;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideFolders = false;
    overrideDevices = false;
    guiAddress = "0.0.0.0:${toString guiPort}";
  };

  services.nginx.proxyHosts."syncthing.jsmart.dev".port = guiPort;
}
