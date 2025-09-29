{
  nixpkgs,
  system ? builtins.currentSystem,
  config ? "AARCH64_bcm2711_verified",
}:
let
  board_config = import ./config.nix;
  args = board_config.${config};
in
nixpkgs.stdenvNoCC.mkDerivation {
  name = "sel4-kernel-${config}";

  src = nixpkgs.fetchgit {
    url = "https://github.com/seL4/seL4.git";
    rev = "f5e45a24531ad9ed28c56efb8346ab7398895fff";
    hash = "sha256-cWMulMMe1+HFWokmroIZdpvM253P2gxbEWOBj3EDYHU=";
  };

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
    args.bintools
    args.cc

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
      -DCROSS_COMPILER_PREFIX=${args.toolchain} \
      -DCMAKE_TOOLCHAIN_FILE=../gcc.cmake \
      -DCMAKE_INSTALL_PREFIX=$out \
      -G Ninja \
      -C ../configs/${config}.cmake \
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
