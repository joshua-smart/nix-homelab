{ fetchFromGitHub, callPackage, ... }:
let
  src = fetchFromGitHub {
    owner = "joshua-smart";
    repo = "portfolio";
    rev = "e25c990422a73557ed42309f7ae1c52d6ab1fd65";
    sha256 = "sha256-wx2yjjbUPj4HHZdc2rif2NhG4i8Mk3ZNFu2vHwvB+QE=";
  };
in
callPackage (import "${src}/portfolio.nix") { }
