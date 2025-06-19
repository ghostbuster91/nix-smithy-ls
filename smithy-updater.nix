{ pkgs, repository, ... }:
let
  cl = "${pkgs.curl}/bin/curl";
  rg = "${pkgs.ripgrep}/bin/rg";
  file = "${repository}-lock.nix";
  name = "${repository}-smithy-updater-script";
  jq = "${pkgs.jq}/bin/jq";

  src = pkgs.writeShellScript name ''
    NEW=$(${cl} -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28"  https://api.github.com/repos/${repository}/smithy-language-server/releases/latest | ${jq} -r '.tag_name' | awk '{sub(/^v/, "")} 1')
    OLD=$(nix eval --json --file ${file} | jq -r  '.version')

    echo "Old version: $OLD"
    echo "New version: $NEW"

    if [ "$NEW" != "$OLD" ]; then
      echo "Updating smithy"
      sed -i "s/$OLD/$NEW/g" ${file}

      nix build .#${repository}-smithy-ls 2> build-result

      OLD_HASH=$(cat build-result | ${rg} specified: | awk -F ':' '{print $2}' | sed 's/ //g')
      NEW_HASH=$(cat build-result | ${rg} got: | awk -F ':' '{print $2}' | sed 's/ //g')

      echo "Old hash: $OLD_HASH"
      echo "New hash: $NEW_HASH"

      rm build-result

      sed -i "s|$OLD_HASH|$NEW_HASH|g" ${file}

      echo "version=$NEW" >> $GITHUB_OUTPUT
    else
      echo "Versions are identical, aborting."
    fi
  '';
in
pkgs.stdenv.mkDerivation
{
  inherit name src;

  phases = [ "installPhase" "patchPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${name}
    chmod +x $out/bin/${name}
  '';
}
