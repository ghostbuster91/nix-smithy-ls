{ pkgs, ... }:
{ artifact, version, outputHash, homepage }:

pkgs.stdenv.mkDerivation rec {
  pname = "smithy_ls";
  inherit version;

  deps = pkgs.stdenv.mkDerivation {
    name = "${pname}-deps-${version}";
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${pkgs.coursier}/bin/cs fetch ${artifact}:${version} > deps
      mkdir -p $out/share/java
      cp -n $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    inherit outputHash;
  };

  nativeBuildInputs = [ pkgs.makeWrapper pkgs.setJavaClassPath ];
  buildInputs = [ deps ];

  dontUnpack = true;

  extraJavaOpts = "-XX:+UseG1GC -XX:+UseStringDeduplication -Xss4m -Xms100m";

  installPhase = ''
    mkdir -p $out/bin

    makeWrapper ${pkgs.jre}/bin/java $out/bin/smithy_ls
  '';

  meta = with pkgs.lib; {
    inherit homepage;
    license = licenses.asl20;
    description = "Language server for smithy";
    maintainers = [ ];
  };
}
