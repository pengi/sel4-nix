{
  name,
  system,
  nixpkgs ? import <nixpkgs> { },
  builder,
  tools ? [ ],
  overlay ? { },
}:
let
  main = ./builder.sh;
in
derivation (
  {
    inherit
      name
      system
      tools
      main
      ;
    buildScript = builder;

    args = [
      "-c"
      "source ${main}; doBuild"
    ];

    builder = "${nixpkgs.bash}/bin/bash";

    buildTools = with nixpkgs; [
      bash
      coreutils
    ];
  }
  // overlay
)
