{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (lib.strings) concatMapStringsSep;
  cfg = config.services.gandi-dynamic-dns;

  update-script = pkgs.writeShellScriptBin "update-record" ''
    # Usage : gandi-update-record subdomain.example.com

    # Test args
    if [ $# -ne 1 ]; then
        printf "\nUsage : $ ''${0##*/} subdomain.example.com \n\n"
        exit
    fi

    # Gandi LiveDNS API KEY
    API_KEY=$GANDI_API_KEY

    SUBDOMAIN=$(echo $1 | ${pkgs.gawk}/bin/awk -F. '{OFS=".";NF=NF-2;print }')
    DOMAIN=$(echo $1 | ${pkgs.gawk}/bin/awk -F. '{print $(NF-1)"."$NF}')

    if [ "$SUBDOMAIN" = "" ];then
        printf "\n%s\n\n" "Error : No subdomain given. Usage : ''${0##*/} subdomain.example.com"
        exit
    fi

    echo "Updating DNS for $SUBDOMAIN.$DOMAIN"

    # Get external IP address
    EXT_IP=$(${pkgs.curl}/bin/curl -4 -s ifconfig.me)

    # Get current IP in record
    CURRENT_IP_IN_RECORD=$(${pkgs.curl}/bin/curl -s \
    --url "https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/$SUBDOMAIN" \
    --request GET \
    --header "Authorization: Apikey $API_KEY" \
    | ${pkgs.jq}/bin/jq -r '.[] | .rrset_values[0]')

    printf "\nExternal IP : %17s\n" $EXT_IP
    printf "IP in DNS record : %s\n" $CURRENT_IP_IN_RECORD

    # If IP's are the same, nothing to do and exit
    if [ "$CURRENT_IP_IN_RECORD" = "$EXT_IP" ]; then
        printf "No change. Exiting...\n\n"
        exit 0
    fi

    # Update the A Record of the subdomain using PUT
    # If record doesn't exist, create one with current external IP
    if [ "$CURRENT_IP_IN_RECORD" = "" ]; then
        printf "Creating DNS A Record...\n"
        MESSAGE="DNS Record Created"
    else
        printf "Udating DNS A Record...\n"
        MESSAGE="DNS Record Updated"
    fi

    RESPONSE=$(${pkgs.curl}/bin/curl -s \
    --url "https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/$SUBDOMAIN" \
    --request PUT \
    --header "Content-Type: application/json" \
    --header "Authorization: Apikey $API_KEY" \
    --data '{
                "items":[ {
                    "rrset_type":"A",
                    "rrset_ttl":1200,
                    "rrset_values":["'$EXT_IP'"]
                } ]
            }' \
    | ${pkgs.jq}/bin/jq -r '.message') 

    if [ "$RESPONSE" = "DNS Record Created" ]; then
        printf "%s\n\n" "$MESSAGE"
    else
        printf "%s\n\n" "$RESPONSE"
    fi

    exit 0
  '';
in
{
  options.services.gandi-dynamic-dns = {
    enable = mkEnableOption "gandi-dynamic-dns";
    domain = mkOption { type = types.str; };
    record-names = mkOption { type = types.listOf types.str; };
    update-interval = mkOption { type = types.str; };
    key-file = mkOption {
      type = types.path;
      description = ''
        Path to a file containing the GANDI_API_KEY environment variable.
      '';
    };
  };

  config = mkIf cfg.enable {

    systemd.services.gandi-ddns = {
      script = concatMapStringsSep "\n" (record: ''
        ${update-script}/bin/update-record ${record}.${cfg.domain}
      '') cfg.record-names;
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        EnvironmentFile = cfg.key-file;
      };
    };

    systemd.timers.gandi-ddns = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/15"; # every 15 minutes
        Unit = "gandi-ddns.service";
      };
    };
  };
}
