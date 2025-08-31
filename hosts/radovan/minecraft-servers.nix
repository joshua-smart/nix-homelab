{
  pkgs,
  ...
}:
{
  users.users.admin.extraGroups = [
    "minecraft"
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = false;

    servers = {
      season-5 = {
        enable = false;
        package = pkgs.minecraftServers.paper-1_21;
        jvmOpts = "-Xms4096M -Xmx8192M";
        serverProperties = {
          server-port = 25566;
        };
      };

      "26t" = {
        enable = false;
        package = pkgs.minecraftServers.paper-1_21_4;
        jvmOpts = "-Xms4096M -Xmx4096M";
        serverProperties = {
          server-port = 25569;
          motd = "Ben go to bed!";
          level-seed = "1412583731547517931";
        };
      };

      "12a" = {
        enable = true;
        package = pkgs.minecraftServers.vanilla-25w35a;
        serverProperties = {
          server-port = 25569;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    25570
    25565
    25569
  ];
}
