{ ... }:
{
  imports = [
    ./profiles
    ./services
  ];

  system.stateVersion = "24.05";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
