{
  nixpkgs,
  system ? builtins.currentSystem,
}:
let
  board_config = import ./config.nix { inherit nixpkgs; };
  sel4_src = nixpkgs.fetchgit {
    url = "https://github.com/seL4/seL4.git";
    rev = "refs/tags/14.0.0";
    hash = "sha256-kzRV3qIsfyIFoc2hT6l0cIyR6zLD4yHcPXCAbGAQGsk=";
  };
in
builtins.mapAttrs (
  config_name: config_args:
  nixpkgs.stdenvNoCC.mkDerivation {
    name = "sel4-kernel-${config_name}";
    src = sel4_src;

    buildInputs = with nixpkgs; [
      (python312.withPackages (
        ps: with ps; [
          pyyaml
          pyfdt
          jinja2
          jsonschema
          ply
        ]
      ))
      config_args.bintools
      config_args.cc

      cmake
      ninja
      dtc
      bash
      libxml2
    ];

    dontUseCmakeConfigure = true;

    patchPhase = ''
      patchShebangs .
    '';

    #phases = [ "unpackPhase" "patchPhase" "configurePhase" "buildPhase" ];

    configurePhase = ''
      mkdir _build
      pushd _build
      cmake \
        -DCROSS_COMPILER_PREFIX=${config_args.toolchain} \
        -DCMAKE_TOOLCHAIN_FILE=../gcc.cmake \
        -DCMAKE_INSTALL_PREFIX=$out \
        -G Ninja \
        -C ../configs/${config_name}.cmake \
        ../
      popd
    '';

    buildPhase = ''
      pushd _build
      ninja kernel.elf
      popd
    '';

    installPhase = ''
      cmake --install _build/
    '';
  }
) board_config
