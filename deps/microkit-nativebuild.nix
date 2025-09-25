{
  nixpkgs,
  system ? builtins.currentSystem,
}:
let

  microkit-src = nixpkgs.fetchgit {
    url = "https://github.com/seL4/microkit.git";
    rev = "d7da977bab18d206ed071fa4bf8fcd35162f5934";
    hash = "sha256-uwiGZx06uZMNLrWuFlL3xVWca9VnGiDRe1Q3MMEvhEY=";
  };

  sel4-src = nixpkgs.fetchgit {
    url = "https://github.com/seL4/seL4.git";
    rev = "f5e45a24531ad9ed28c56efb8346ab7398895fff";
    hash = "sha256-cWMulMMe1+HFWokmroIZdpvM253P2gxbEWOBj3EDYHU=";
  };

  microkit-tool = nixpkgs.rustPlatform.buildRustPackage rec {
    pname = "microkit-tool";
    version = microkit-version;

    src = microkit-src;
    sourceRoot = "${src.name}/tool/microkit";

    cargoHash = "sha256-LL4SMrm1tXyOPqsT7Tj4xCYKIi2MQYfZbz7zxiFYDkI=";
  };

  boards = with nixpkgs.pkgsCross; {
    tqma8xqp1gb = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    zcu102 = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    maaxboard = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    imx8mm_evk = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    imx8mp_evk = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    imx8mq_evk = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    imx8mp_iotgate = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    odroidc2 = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    odroidc4 = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    ultra96v2 = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    qemu_virt_aarch64 = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    qemu_virt_riscv64 = {
      stdenv = riscv64-embedded.stdenv;
      target-triple = "riscv64-none-elf";
    };
    rpi4b_1gb = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    rpi4b_2gb = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    rpi4b_4gb = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    rpi4b_8gb = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    rockpro64 = {
      stdenv = aarch64-embedded.stdenv;
      target-triple = "aarch64-none-elf";
    };
    hifive_p550 = {
      stdenv = riscv64-embedded.stdenv;
      target-triple = "riscv64-none-elf";
    };
    star64 = {
      stdenv = riscv64-embedded.stdenv;
      target-triple = "riscv64-none-elf";
    };
    ariane = {
      stdenv = riscv64-embedded.stdenv;
      target-triple = "riscv64-none-elf";
    };
    cheshire = {
      stdenv = riscv64-embedded.stdenv;
      target-triple = "riscv64-none-elf";
    };
  };

  microkit-version = "2.0.1-d7da977";
  sel4-version = "sel4-f5e45a2";

  sdk-version = "${microkit-version}-${sel4-version}";
in
{
  board = builtins.mapAttrs (board: args: {
    inherit board;
    inherit (args) stdenv target-triple;
    sdk = nixpkgs.stdenvNoCC.mkDerivation {
      name = "microkit-sdk-${board}-${sdk-version}";

      dontUseCmakeConfigure = true;

      buildInputs = with nixpkgs; [
        (nixpkgs.python312.withPackages (
          ps: with ps; [
            mypy
            black
            flake8
            ply
            jinja2
            pyyaml
            pyfdt
            lxml

            jsonschema
          ]
        ))

        # For sel4
        args.stdenv.cc.bintools
        args.stdenv.cc

        cmake
        ninja
        dtc
        bash
        libxml2
        qemu
      ];

      srcs = [
        microkit-src
        sel4-src
      ];

      sourceRoot = "${microkit-src.name}";

      patchPhase = ''
        patchShebangs ..
      '';

      buildPhase = ''
        python build_sdk.py \
          --sel4=../${sel4-src.name} \
          --version ${sdk-version} \
          --gcc-toolchain-prefix-aarch64="aarch64-none-elf" \
          --gcc-toolchain-prefix-riscv64="riscv64-none-elf" \
          --board ${board} \
          --skip-tool \
          --skip-docs \
          --skip-tar
      '';

      installPhase = ''
        ls -1 release
        cp -r release/microkit-sdk-${sdk-version} $out
        cp ${microkit-tool}/bin/microkit $out/bin/
      '';

      fixupPhase = ":";
    };
  }) boards;

  doc = nixpkgs.stdenvNoCC.mkDerivation {
    name = "microkit-doc-${sdk-version}";

    buildInputs = with nixpkgs; [
      pandoc
      (texliveSmall.withPackages (
        ps: with ps; [
          collection-latexextra # TODO: slim down a lot
          roboto
        ]
      ))
    ];

    TEXINPUTS = "style:";

    src = microkit-src;

    patchPhase = ''
      patchShebangs .
    '';

    buildPhase = ''
      pushd docs
      pandoc manual.md -o ../microkit_user_manual.pdf
      popd
    '';

    installPhase = ''
      mkdir $out
      cp microkit_user_manual.pdf $out/
    '';

    fixupPhase = ":";
  };

  example = nixpkgs.stdenvNoCC.mkDerivation {
    name = "microkit-example-${sdk-version}";

    buildInputs = [];

    src = microkit-src;

    buildPhase = ":";

    installPhase = ''
      cp -r example $out
    '';

    fixupPhase = ":";
  };
}
