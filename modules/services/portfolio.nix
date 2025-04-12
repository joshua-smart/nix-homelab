{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.portfolio;
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    concatStringsSep
    ;

  args = concatStringsSep " " [
    "--port ${toString cfg.port}"
    "--address ${cfg.host}"
    "--asset-dir ${pkgs.portfolio}/assets"
    "--data-path ${cfg.dataDir}/data.ron"
  ];
in
{
  options.services.portfolio = {
    enable = mkEnableOption "portfolio";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
    port = mkOption {
      type = types.port;
      default = 3001;
    };
    host = mkOption {
      type = types.str;
      default = "localhost";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/portfolio";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.portfolio = {
      description = "Personal portfolio website";
      serviceConfig = {
        ExecStart = "${pkgs.portfolio}/bin/portfolio ${args}";
        DynamicUser = true;
        User = "portfolio";
        Group = "portfolio";
        StateDirectory = "portfolio";
        WorkingDirectory = cfg.dataDir;
        Restart = "always";
      };
      preStart = ''
        if [ ! -e "${cfg.dataDir}/data.ron" ]; then
          echo "( projects: {}, events: {} )" > "${cfg.dataDir}/data.ron"
        fi
      '';
      after = [ "network.target" ];
    };
  };
}
