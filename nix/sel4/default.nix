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

  sel4_build_deps = with nixpkgs; [
    (python312.withPackages (
      ps: with ps; [
        pyyaml
        pyfdt
        jinja2
        jsonschema
        ply
        lxml
      ]
    ))

    cmake
    ninja
    dtc
    bash
    libxml2
  ];

  sel4_build = (
    {
      name,
      cc,
      cmake_args ? "",
      deps ? [ ],
    }:
    nixpkgs.stdenvNoCC.mkDerivation {
      inherit cc;

      name = "sel4-kernel-${name}";
      src = sel4_src;

      buildInputs = [
        cc.bintools
        cc
      ]
      ++ sel4_build_deps
      ++ deps;

      dontUseCmakeConfigure = true;

      patchPhase = ''
        patchShebangs .
      '';

      #phases = [ "unpackPhase" "patchPhase" "configurePhase" "buildPhase" ];

      configurePhase = ''
        mkdir _build
        pushd _build
        cmake \
          -DCROSS_COMPILER_PREFIX=${cc.targetPrefix} \
          -DCMAKE_TOOLCHAIN_FILE=../gcc.cmake \
          -DCMAKE_INSTALL_PREFIX=$out \
          -G Ninja \
          ${cmake_args} \
          ../
        popd
      '';

      buildPhase = ''
        pushd _build
        ninja sel4_generated
        ninja kernel.elf
        popd
      '';

      installPhase = ''
        cmake --install _build/
      '';
    }
  );

  sel4_build_defs =
    {
      name,
      cc,
      args ? { },
      deps ? [ ],
    }:
    sel4_build {
      inherit name cc deps;
      cmake_args = builtins.concatStringsSep " " (
        builtins.sort builtins.lessThan (
          builtins.attrValues (builtins.mapAttrs (name: value: "-D${name}=\"${value}\"") args)
        )
      );
    };
in
{
  verified = builtins.mapAttrs (
    name: cc:
    sel4_build {
      inherit name cc;
      deps = [ ];
      cmake_args = "-C ../configs/${name}.cmake";
    }
  ) board_config;

  custom =
    {
      cc,
      plat,
      args ? { },
      deps ? [ ],
    }:
    sel4_build_defs {
      inherit cc deps;
      name = "${cc.targetPrefix}${plat}";
      args = {
        KernelPlatform = plat;
      }
      // args;
    };

  custom_mcs =
    {
      cc,
      plat,
      args ? { },
      deps ? [ ],
    }:
    sel4_build_defs {
      inherit cc deps;
      name = "${cc.targetPrefix}${plat}-MCS";
      args = {
        KernelPlatform = plat;
        KernelIsMCS = "1";
        KernelStaticMaxPeriodUs = "(60 * 60 * MS_IN_S * US_IN_MS)";
      }
      // args;
    };
}
