{
  mk-sdk,
  mkDerivation,
}:
let
  apps = map (app: (import app { inherit mk-sdk mkDerivation; })) [
    ../apps/empty
    ../apps/rpi4b/timer
  ];

  app_search_paths = builtins.concatStringsSep " " (builtins.map (app: "--search-path \"${app}\"") apps);
in
mkDerivation {
  name = "example-target";

  src = ./src;

  buildInputs = [
    mk-sdk
  ];

  inherit apps;

  buildPhase = ''
    mkdir build
    microkit \
      main.system \
      -o build/loader.img \
      -r build/report.txt \
      --board "${mk-sdk.board}" \
      --config "${mk-sdk.config}" \
      ${app_search_paths}
  '';

  installPhase = ''
    cp -r build $out
  '';

  # Don't run patchelf on embedded
  fixupPhase = ":";
}
