{ ... }:
{
  networking.services."syncthing.jsmart.dev".port = 8082;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideFolders = false;
    overrideDevices = false;
    guiAddress = "127.0.0.1:8082";
    settings.gui.insecureSkipHostcheck = true;
  };
}
