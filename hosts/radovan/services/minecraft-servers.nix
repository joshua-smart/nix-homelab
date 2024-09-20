{
  config,
  pkgs,
  nix-minecraft,
  ...
}:
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ nix-minecraft.overlay ];

  profiles.user.groups = [ "minecraft" ];

  age.secrets."restic-password".file = ../../../secrets/restic-password.age;

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.season-5 = {
      enable = true;
      package = pkgs.minecraftServers.paper-1_21;
      jvmOpts = "-Xms4096M -Xmx8192M";
      serverProperties = {
        server-port = 25566;
      };
    };
  };

  services.restic.backups = {
    minecraft-server-season-5 = {
      paths = [ "${config.services.minecraft-servers.dataDir}/season-5" ];
      timerConfig = {
        OnCalendar = "*-*-* 12:00:00";
        Persistent = true;
      };
      initialize = true;
      repository = "/bulk/backups/minecraft-server-season-5";
      passwordFile = config.age.secrets."restic-password".path;
      pruneOpts = [ "--keep-last 5" ];
    };
  };
}
