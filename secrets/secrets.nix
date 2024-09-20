let
  js-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN";
  js-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg";

  admins = [
    js-laptop
    js-desktop
  ];

  radovan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5Ibd1yonZVXAgjmY50a9OHYLbKWKLKrLjFl/Bbw8eP";
  falen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGkC1u+4buld3EErSn4hx9T0F5ldkhUhpM/RNMYRLjzh";
in
{
  "wireguard-private-key.age".publicKeys = [ radovan ] ++ admins;

  "gandi-api-key.env.age".publicKeys = [
    radovan
    falen
  ] ++ admins;

  "26t-network.env.age".publicKeys = [ falen ] ++ admins;

  "restic-password.age".publicKeys = [ radovan ] ++ admins;

  "nextcloud-root-password.age".publicKeys = [ radovan ] ++ admins;

  "vaultwarden.env.age".publicKeys = [ radovan ] ++ admins;

  "homepage.env.age".publicKeys = [ radovan ] ++ admins;
}
