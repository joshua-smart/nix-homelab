{ fetchFromGitHub, callPackage, ... }:
let
  src = fetchFromGitHub {
    owner = "joshua-smart";
    repo = "portfolio";
    rev = "f829738e5003c358e2b5090b73c4c316df85ceba";
    sha256 = "sha256-Ayv4wMcTKPtQJnFyCcdiJo2vXKi0wCIzgEUEnUvxqFQ=";
  };
in
callPackage (import "${src}/portfolio.nix") { }
