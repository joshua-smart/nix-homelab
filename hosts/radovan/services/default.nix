{ ... }:
{
  imports = [
    ./minecraft-servers.nix
    ./wireguard.nix
    ./vaultwarden.nix
    ./paperless.nix
    ./portfolio.nix
    ./nextcloud.nix
    ./homepage-dashboard.nix
  ];
}
