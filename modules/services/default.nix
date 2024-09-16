{ ... }:
{
  imports = [
    ./gandi-dynamic-dns.nix
    ./openssh.nix
    ./fail2ban.nix
    ./nginx.nix
    ./wireguard.nix
    ./adguardhome.nix
  ];
}
