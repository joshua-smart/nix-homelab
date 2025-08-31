let
  js-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN";
  js-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg";

  admins = [
    js-laptop
    js-desktop
  ];

  radovan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5Ibd1yonZVXAgjmY50a9OHYLbKWKLKrLjFl/Bbw8eP";
  falen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPn618NF7nhtOVyTu8jrY9frIBFlUKkoG6XEGubHLRjG";
in
builtins.mapAttrs (key: hosts: { publicKeys = hosts ++ admins; }) {
  "wireguard-private-key.age" = [ radovan ];
  "26t-network.env.age" = [ falen ];
  "restic-password.age" = [ radovan ];
  "nextcloud-root-password.age" = [ radovan ];
  "vaultwarden.env.age" = [ radovan ];
  "velocity-forwarding.secret.age" = [ radovan ];
  "cloudflare-ddns-token.age" = [
    radovan
    falen
  ];
  "radovan-root-hashed-password.age" = [ radovan ];
  "radovan-admin-hashed-password.age" = [ radovan ];
  "radovan-headscale-auth-key.age" = [ radovan ];
  "falen-headscale-auth-key.age" = [ falen ];
  "ntfy-admin-password.age" = [ radovan ];
}
