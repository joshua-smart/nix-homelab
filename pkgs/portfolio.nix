{ fetchFromGitHub, callPackage, ... }:
let
  src = fetchFromGitHub {
    owner = "joshua-smart";
    repo = "portfolio";
    rev = "ee0a69a8557262482a4a5e783a27ef6b5a6841ea";
    sha256 = "sha256-Dm4siVYoLvSGsxFeOVgIMnZjlqekMkWFgAOIaFS8Cn0=";
  };
in
callPackage (import "${src}/portfolio.nix") { }
