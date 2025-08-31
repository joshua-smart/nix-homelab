{ lib, ... }:
let
  inherit (lib) filesystem;
in
{
  imports = filesystem.listFilesRecursive ./services;

  system.stateVersion = "24.05";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
