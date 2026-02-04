{
  mk-sdk,
  mkDerivation,
}:
let
  a = 1;
in
mkDerivation {
  name = "empty-app";

  buildInputs = [
    mk-sdk.cc
    mk-sdk.cc.bintools
  ];

  sdk = mk-sdk;
  CPU = "${mk-sdk.gcc_cpu}";
  TARGET_PREFIX = "${mk-sdk.cc.targetPrefix}";
  BOARD = "${mk-sdk.board}";
  CONFIG = "${mk-sdk.config}";
  MICROKIT_SDK = "${mk-sdk}";

  srcs = ./src;

  buildPhase = ''
    mkdir build
    make BUILD_DIR=build
  '';

  # Don't run patchelf on embedded
  fixupPhase = ":";
}
