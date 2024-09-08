{ ... }:
{
  imports = [
    ./gandi-dynamic-dns.nix
    ./openssh.nix
    ./fail2ban.nix
    ./paperless.nix
    ./nginx.nix
    ./wireguard.nix
    ./adguardhome.nix
    ./nextcloud.nix
    ./portfolio.nix
  ];
}
