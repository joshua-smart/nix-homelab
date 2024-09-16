{ lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep;
  portfolio = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "joshua-smart";
    repo = "portfolio";
    rev = "c06b9934cc4312dce3ca98e15d109d2f9bc0fe28";
    sha256 = "sha256-YoJJfJcFIINS/tk6GBhiEqiBUlGKvdEsznFgcoCmowk=";
  }) { };

  args = concatStringsSep " " [
    "--port ${toString port}"
    "--address ${address}"
    "--asset-dir ${portfolio}/assets"
    "--data-path \${STATE_DIRECTORY}/data.ron"
  ];

  port = 3001;
  address = "127.0.0.1";
in
{
  networking.firewall.allowedTCPPorts = [ port ];

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

  services.nginx.proxyHosts."jsmart.dev".port = port;
}
