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
            disney-smithy-ls = smithyBuilder {
              artifact = "com.disneystreaming.smithy:smithy-language-server";
              version = "0.0.20";
              outputHash = "sha256-hDhs5zCSy3s6rHBV662hTFRdMngcPiKw6ei6oWUwGnY=";
              homepage = "https://github.com/disneystreaming/smithy-language-server";
            };
            aws-smithy-ls = smithyBuilder {
              artifact = "software.amazon.smithy:smithy-language-server";
              version = "0.2.3";
              outputHash = "sha256-uCkiPveRkmzU3neM+nUDV2ODRcqWUr0awVbWmrM04g4=";
              homepage = "https://github.com/awslabs/smithy-language-server";
            };
          };
        }
      );
}
