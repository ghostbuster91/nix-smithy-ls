{
  description = "Smithy language server";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          smithyBuilder = import ./smithy-ls.nix { inherit pkgs; };
        in
        {
          packages = {
            smithy-ls = smithyBuilder {
              version = "0.0.20";
              outputHash = "sha256-hDhs5zCSy3s6rHBV662hTFRdMngcPiKw6ei6oWUwGnY=";
            };
          };
        }
      );
}
