{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mapAttrsToList filterAttrs;
in
{
  environment.systemPackages = (
    mapAttrsToList (
      name: cfg:
      pkgs.writeShellScriptBin "tmux-minecraft-server-${name}" ''
        tmux -S ${cfg.managementSystem.tmux.socketPath name} attach
      ''
    ) (filterAttrs (_: cfg: cfg.enable) config.services.minecraft-servers.servers)
  );

  users.users.admin.extraGroups = [
    "minecraft"
  ];

  networking.firewall.allowedTCPPorts = [ 25566 ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers = {
      forever-world = {
        enable = false;
        package = pkgs.minecraftServers.fabric-1_21_10;
        jvmOpts = "-Xmx4096M -Xmx8192M";
        serverProperties = {
          server-port = 25566;
        };
      };

      echo = {
        enable = false;
        package = pkgs.minecraftServers.fabric-1_21_11;
        jvmOpts = "-Xms4096M -Xmx8192M";
        serverProperties = {
          server-port = 25565;
          whitelist = true;
          white-list = true;
          enforce-whitelist = true;
          level-seed = "-3078894166230307060";
          spawn-protection = 0;
          pause-when-empty-seconds = -1;
        };
        symlinks = {
          mods = pkgs.linkFarmFromDrvs "mods" (
            builtins.attrValues {
              Lithium = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/gl30uZvp/lithium-fabric-0.21.2+mc1.21.11.jar";
                sha256 = "sha256:0f87ggnrhxbnhm51wja8zp83mzjd2nlfgrg5zd5z88zffff661ii";
              };
              FerriteCore = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/uXXizFIs/versions/eRLwt73x/ferritecore-8.0.3-fabric.jar";
                sha256 = "sha256-yG6rrNvwY5ibLKgSyOk/VWuP7/HJ38B8rvodkKXHvzU=";
              };
              Carpet = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/HzPcczDK/fabric-carpet-1.21.11-1.4.194+v251223.jar";
                sha256 = "sha256-G01m8DMr2l3u4IdV5JPC1qxk1k1SheETSqA2BJdcJSE=";
              };
              PlayerRoles = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/2PHCrWcd/player-roles-1.8.1.jar";
                sha256 = "sha256-ocyGw0I4EtQLO2q8OTBch/PNbTU25d6ktCwpG7HXF7c=";
              };
              FabricApi = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/DdVHbeR1/fabric-api-0.141.1+1.21.11.jar";
                sha256 = "sha256-ald/g72LM8lAQSfRZTGsycQZX0feA5WVfJ1M0J17mMY=";
              };
              Chunky = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/fALzjamp/versions/1CpEkmcD/Chunky-Fabric-1.4.55.jar";
                sha256 = "sha256-M8vZvODjNmhRxLWYYQQzNOt8GJIkjx7xFAO77bR2vRU=";
              };
            }
          );
          "config/roles.json".value = {
            admin = {
              level = 100;
              overrides = {
                permission_level = 4;
                command_feedback = true;
                commands = {
                  ".*" = "allow";
                };
              };
            };
            whitelister = {
              level = 1;
              overrides = {
                commands = {
                  "whitelist .*" = "allow";
                };
              };
            };
            everyone = { };
          };
        };
      };

      # season-5 = {
      #   enable = false;
      #   package = pkgs.minecraftServers.paper-1_21;
      #   jvmOpts = "-Xms4096M -Xmx8192M";
      #   serverProperties = {
      #     server-port = 25566;
      #   };
      # };

      # "26t" = {
      #   enable = false;
      #   package = pkgs.minecraftServers.paper-1_21_4;
      #   jvmOpts = "-Xms4096M -Xmx4096M";
      #   serverProperties = {
      #     server-port = 25569;
      #     motd = "Ben go to bed!";
      #     level-seed = "1412583731547517931";
      #   };
      # };

      # "12a" = {
      #   enable = true;
      #   package = pkgs.minecraftServers.vanilla-25w35a;
      #   serverProperties = {
      #     server-port = 25569;
      #   };
      # };
    };
  };
}
