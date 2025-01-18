{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (inputs) nix-minecraft;
  inherit (lib) mkIf filterAttrs mapAttrsToList;
  cfg = config.services.minecraft-servers;
in
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  config =
    let
      servers = filterAttrs (_: cfg: cfg.enable) cfg.servers;
    in
    {
      environment.systemPackages = mkIf cfg.enable (
        mapAttrsToList (
          name: cfg:
          pkgs.writeShellScriptBin "tmux-minecraft-server-${name}" ''
            tmux -S ${cfg.managementSystem.tmux.socketPath name} attach
          ''
        ) servers
      );
    };
}
