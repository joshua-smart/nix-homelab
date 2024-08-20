let
  js-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN";
  js-desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLqvqY/GcYXdRtZQThNOtSBl7xjPhEx8ZuzzwO9f7Cg";

  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7rkElzd36ff+EnWqAfXz/VedtqGqOfpshFf6wDsOSx";
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6VugWcm6Pf9Prt1t0jz4CTI0ylB6BXD/kLf/I2BJoA";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5Ibd1yonZVXAgjmY50a9OHYLbKWKLKrLjFl/Bbw8eP";
in
{
  "wireguard-private-key.age".publicKeys = [
    server
    js-laptop
  ];

  "gandi-api-key.env.age".publicKeys = [
    server
    js-laptop
  ];

  "nas-credentials.age".publicKeys = [
    laptop
    js-laptop
  ];
}
