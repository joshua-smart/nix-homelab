{ ... }:
{
  imports = [
    ./gandi-dynamic-dns.nix
    ./openssh.nix
    ./fail2ban.nix
    ./paperless.nix
    ./nginx.nix
  ];
}
