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
    "--asset-dir ${pkgs.myPackages.portfolio}/assets"
    "--data-path ${pkgs.myPackages.portfolio}/data.ron"
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
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.portfolio = {
      description = "Personal portfolio website";
      serviceConfig = {
        ExecStart = "${pkgs.myPackages.portfolio}/bin/portfolio ${args}";
        DynamicUser = true;
        User = "portfolio";
        Group = "portfolio";
        StateDirectory = "portfolio";
        WorkingDirectory = "/var/lib/portfolio";
        Restart = "always";
      };
      after = [ "network.target" ];
    };
  };
}
