{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    concatStringsSep
    ;
  cfg = config.services.portfolio;

  portfolio = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "joshua-smart";
    repo = "portfolio";
    rev = "c06b9934cc4312dce3ca98e15d109d2f9bc0fe28";
    sha256 = "sha256-YoJJfJcFIINS/tk6GBhiEqiBUlGKvdEsznFgcoCmowk=";
  }) { };

  args = concatStringsSep " " [
    "--port ${toString cfg.port}"
    "--address ${cfg.address}"
    "--asset-dir ${portfolio}/assets"
    "--data-path \${STATE_DIRECTORY}/data.ron"
  ];
in
{
  options.services.portfolio = {
    enable = mkEnableOption "portfolio";
    port = mkOption {
      type = types.port;
      default = 3001;
    };
    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.portfolio = {
      description = "Personal portfolio website.";
      serviceConfig = {
        ExecStart = "${portfolio}/bin/portfolio ${args}";
        StateDirectory = "portfolio";
      };

      preStart = ''
        if [ ! -e "$STATE_DIRECTORY/data.ron" ]; then
          echo "( projects: {}, events: {} )" > "$STATE_DIRECTORY/data.ron"
        fi
      '';

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      unitConfig = {
        StartLimitIntervalSec = 5;
        StartLimitBurst = 10;
      };
    };

    services.nginx.proxyHosts."jsmart.dev".port = cfg.port;
  };
}
