{ ... }:
{
  imports = [
    ./actual.nix
    ./minecraft-servers
    ./wireguard.nix
    ./vaultwarden.nix
    ./paperless.nix
    ./portfolio.nix
    ./nextcloud.nix
    ./homepage-dashboard.nix
    ./syncthing.nix
  ];
}
