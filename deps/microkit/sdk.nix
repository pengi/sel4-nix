{
  mkDerivation,
  nixpkgs,

  board,
  config,

  attrs,

  microkit-src,
  sel4-src,

  sdk-version,
}:
let

  stdenv_arch = {
    aarch64 = nixpkgs.pkgsCross.aarch64-embedded.stdenv;
    riscv64 = nixpkgs.pkgsCross.riscv64-embedded.stdenv;
  };

  sel4-python = nixpkgs.python312.withPackages (
    ps: with ps; [
      ply
      jinja2
      pyyaml
      pyfdt
      lxml
      jsonschema
    ]
  );

  defines = attrs.kernel_options // {
    CROSS_COMPILER_PREFIX = "${attrs.arch}-none-elf-"; # gcc - use -DTRIPLE=arch for llvm
    PYTHON3 = "${sel4-python}/bin/python";
    KernelSel4Arch = "${attrs.arch}";
  };

  config_strs = builtins.concatStringsSep " " (
    builtins.sort builtins.lessThan (
      builtins.attrValues (builtins.mapAttrs (name: value: "-D${name}=${value}") defines)
    )
  );

  sel4-build = mkDerivation {
    name = "sel4-${board}-${config}";
    version = sdk-version;

    buildInputs = [
      stdenv_arch.${attrs.arch}.cc.bintools
      stdenv_arch.${attrs.arch}.cc

      nixpkgs.cmake
      nixpkgs.ninja
      nixpkgs.dtc
      nixpkgs.libxml2
    ];

    dontUseCmakeConfigure = true;

    src = sel4-src;

    patchPhase = ''
      patchShebangs .
    '';

    buildPhase = ''
      mkdir build
      cmake -GNinja -DCMAKE_INSTALL_PREFIX=$out ${config_strs} -B build
      cmake --build build
    '';

    installPhase = ''
      cmake --install build
      cp build/generated/invocations_all.json $out/
    '';

    # Don't run patchelf on embedded
    fixupPhase = ":";
  };

  tool-build = nixpkgs.rustPlatform.buildRustPackage rec {
    pname = "microkit-tool";
    version = sdk-version;

    src = microkit-src;
    sourceRoot = "${src.name}/tool/microkit";

    cargoHash = "sha256-LL4SMrm1tXyOPqsT7Tj4xCYKIi2MQYfZbz7zxiFYDkI=";
  };

  sel4-gen-config = builtins.fromJSON (
    builtins.readFile "${sel4-build}/libsel4/include/kernel/gen_config.json"
  );

  loader-env = {
    LINK_ADDRESS = attrs.loader_link_address;
    PRINTING = if config == "debug" then "1" else "0";
  }
  // (
    if attrs.arch == "aarch64" then
      {
        PHYSICAL_ADDRESS_BITS =
          if sel4-gen-config.ARM_PA_SIZE_BITS_40 then
            "40"
          else if sel4-gen-config.ARM_PA_SIZE_BITS_44 then
            "44"
          else
            throw "unknown physical address size";
      }
    else if attrs.arch == "riscv64" then
      {
        FIRST_HART_ID = sel4-gen-config.FIRST_HART_ID;
      }
    else
      { }
  );

  build-elf = (
    component_name: defines:
    mkDerivation (
      {
        name = "microkit-${component_name}-${board}-${config}";
        version = sdk-version;

        buildInputs = [
          stdenv_arch.${attrs.arch}.cc.bintools
          stdenv_arch.${attrs.arch}.cc
        ];

        dontUseCmakeConfigure = true;

        ARCH = attrs.arch;
        BOARD = board;
        TARGET_TRIPLE = "${attrs.arch}-none-elf";

        SEL4_SDK = "${sel4-build}/libsel4";

        # Only supporting gcc for now
        LLVM = "false";
        GCC_CPU = "${attrs.gcc_cpu}";

        src = microkit-src;

        patchPhase = ''
          patchShebangs .
        '';

        buildPhase = ''
          mkdir build
          BUILD_DIR=$PWD/build make -C ${component_name}
        '';

        installPhase = ''
          mkdir $out
          cp build/${component_name}.elf $out/
        '';

        # Don't run patchelf on embedded
        fixupPhase = ":";
      }
      // defines
    )
  );

  build-lib = (
    component_name: defines:
    mkDerivation (
      {
        name = "microkit-${component_name}-${board}-${config}";

        buildInputs = [
          stdenv_arch.${attrs.arch}.cc.bintools
          stdenv_arch.${attrs.arch}.cc
        ];

        dontUseCmakeConfigure = true;

        ARCH = attrs.arch;
        BOARD = board;
        TARGET_TRIPLE = "${attrs.arch}-none-elf";

        SEL4_SDK = "${sel4-build}/libsel4";

        # Only supporting gcc for now
        LLVM = "false";
        GCC_CPU = "${attrs.gcc_cpu}";

        src = microkit-src;

        patchPhase = ''
          patchShebangs .
        '';

        buildPhase = ''
          mkdir build
          BUILD_DIR=$PWD/build make -C ${component_name}
        '';

        # TODO: Only custom part from build-elf - generalize?
        installPhase = ''
          mkdir $out
          find . -name 'microkit.ld'
          cp libmicrokit/microkit.ld $out/microkit.ld
          cp build/libmicrokit.a $out/libmicrokit.a
          cp -r libmicrokit/include $out/include
        '';

        # Don't run patchelf on embedded
        fixupPhase = ":";
      }
      // defines
    )
  );

  deps = {
    sel4 = sel4-build;
    tool = tool-build;
    loader = build-elf "loader" loader-env;
    monitor = build-elf "monitor" { };
    lib = build-lib "libmicrokit" { };
  };
in
mkDerivation {
  name = "microkit-${board}-${config}";

  buildInputs = [ ];

  dontUseCmakeConfigure = true;

  src = microkit-src;

  patchPhase = ":";

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out
    mkdir -p $out/bin
    mkdir -p $out/board/${board}/${config}/elf
    mkdir -p $out/board/${board}/${config}/lib
    mkdir -p $out/board/${board}/${config}/include

    cp ${deps.tool}/bin/microkit $out/bin/

    cp -r ${deps.loader}/loader.elf $out/board/${board}/${config}/elf/
    cp -r ${deps.monitor}/monitor.elf $out/board/${board}/${config}/elf/

    cp ${deps.sel4}/bin/kernel.elf $out/board/${board}/${config}/elf/sel4.elf
    cp ${deps.sel4}/invocations_all.json $out/board/${board}/${config}/
    cp -r ${deps.sel4}/libsel4/include/* $out/board/${board}/${config}/include/

    cp ${deps.sel4}/support/platform_gen.json $out/board/${board}/${config}/

    cp ${deps.lib}/libmicrokit.a $out/board/${board}/${config}/lib/
    cp ${deps.lib}/microkit.ld $out/board/${board}/${config}/lib/
    cp ${deps.lib}/include/* $out/board/${board}/${config}/include/

    cp -r example $out/
    cp -r LICENSES $out/
    cp LICENSE.md $out/

    echo '${sdk-version}' > $out/VERSION
  '';

  # Don't run patchelf on embedded
  fixupPhase = ":";
}
