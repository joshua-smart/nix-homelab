let
  js-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3PCmL6yPMIM3iV1CSoWmrAknwgFSEwQmGp6xBEs5NN";

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
}
