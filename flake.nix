{
  description = "Smithy Language Server";

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
          awsLock = import ./aws-lock.nix;
          disneyLock = import ./disney-lock.nix;
        in
        {
          packages = {
            disney-smithy-ls = smithyBuilder {
              artifact = "com.disneystreaming.smithy:smithy-language-server";
              inherit (disneyLock) version outputHash;
              homepage = "https://github.com/disneystreaming/smithy-language-server";
            };
            aws-smithy-ls = smithyBuilder {
              artifact = "software.amazon.smithy:smithy-language-server";
              inherit (awsLock) version outputHash;
              homepage = "https://github.com/awslabs/smithy-language-server";
            };
            disney-smithy-updater = import ./disney-smithy-updater.nix { inherit pkgs; };
          };
        }
      );
}
