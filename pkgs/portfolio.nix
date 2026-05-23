{ fetchFromGitHub, callPackage, ... }:
let
  src = fetchFromGitHub {
    owner = "joshua-smart";
    repo = "portfolio";
    rev = "b8e17b1c5017c2f33b670e9901dc2d701f40b866";
    sha256 = "sha256-uUXqKGDDy3nIIVikDRPCxW0Q8odZWAjL1Td8VD+iKw0=";
  };
in
callPackage (import "${src}/portfolio.nix") { }
