{
  config,
  pkgs,
  lib,
  ...
}:
let
  withVelocity = lib.recursiveUpdate {
    serverProperties = {
      online-mode = false;
    };
    files."config/paper-global.yml".value = {
      proxies.velocity = {
        enabled = true;
        online-mode = true;
        secret = "<MARKER>";
      };
    };
    extraStartPre = # bash
      ''
        SECRET=$(cat ${config.age.secrets."velocity-forwarding.secret".path})
        sed -e "s/<MARKER>/$SECRET/g" -i config/paper-global.yml
      '';
  };
in
{
  profiles.user.groups = [
    "minecraft"
  ];

  age.secrets = {
    "restic-password".file = ../../../../secrets/restic-password.age;
    "velocity-forwarding.secret" = {
      file = ../../../../secrets/velocity-forwarding.secret.age;
      owner = "minecraft";
      group = "minecraft";
    };
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = false;

    servers = {
      season-5 = withVelocity {
        enable = false;
        package = pkgs.minecraftServers.paper-1_21;
        jvmOpts = "-Xms4096M -Xmx8192M";
        serverProperties = {
          server-port = 25566;
        };
      };

      hardcore-26t = withVelocity {
        enable = false;
        package = pkgs.minecraftServers.paper-1_21_4;
        jvmOpts = "-Xms4096M -Xmx8192M";
        serverProperties = {
          difficulty = 3;
          server-port = 25567;
          hardcore = true;
        };
      };

      prominence-ii = {
        enable = false;
        package = pkgs.minecraftServers.fabric-1_20_1;
        jvmOpts = "-Xms4096M -Xmx8192M";
        serverProperties = {
          server-port = 25568;
        };
        openFirewall = true;
      };

      velocity = {
        enable = true;
        package = pkgs.velocityServers.velocity;
        stopCommand = # bash
          ''end'';
        symlinks."velocity.toml".value = {
          config-version = "2.7";
          bind = "0.0.0.0:25565";
          player-info-forwarding-mode = "modern";
          ping-passthrough = "all";
          online-mode = true;
          forwarding-secret-file = config.age.secrets."velocity-forwarding.secret".path;

          servers = {
            lobby = "127.0.0.1:25568";
            season-5 = "127.0.0.1:25566";
            hardcore-26t = "127.0.0.1:25567";
          };

          forced-hosts = {
            "season5.minecraft.jsmart.dev" = [ "season-5" ];
            "hardcore26t.minecraft.jsmart.dev" = [ "hardcore-26t" ];
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    25565
    25570
  ];

  services.restic.backups = {
    # minecraft-server-season-5 = {
    #   paths = [ "${config.services.minecraft-servers.dataDir}/season-5" ];
    #   timerConfig = {
    #     OnCalendar = "*-*-* 12:00:00";
    #     Persistent = true;
    #   };
    #   initialize = true;
    #   repository = "/bulk/backups/minecraft-server-season-5";
    #   passwordFile = config.age.secrets."restic-password".path;
    #   pruneOpts = [ "--keep-last 5" ];
    # };
  };
}
