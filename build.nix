{
  system,
  pkgs,
  microkit,
}:
pkgs.stdenvNoCC.mkDerivation {
  name = "sel4-pi4";

  inherit system;

  src = ./src;
  nativeBuildInputs = [ ];

  configurePhase = ''
    true
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    cp -r out $out
  '';
}
