{
  nixpkgs,
}:
let
  stdenv_arch = {
    aarch64 = nixpkgs.pkgsCross.aarch64-embedded.stdenv;
    riscv64 = nixpkgs.pkgsCross.riscv64-embedded.stdenv;
  };

  default_kernel_options = {
    "KernelIsMCS" = true;
  };

  default_kernel_options_arch = {
    aarch64 = {
      "KernelArmExportPCNTUser" = true;
      "KernelArmHypervisorSupport" = true;
      "KernelArmVtimerUpdateVOffset" = false;
      "KernelAllowSMCCalls" = true;
    };
    riscv64 = {
    };
  };

  configs = {
    release = {
      debug = false;
      kernel_options = { };
      kernel_options_arch = {
        aarch64 = { };
        riscv64 = { };
      };
    };
    debug = {
      debug = true;
      kernel_options = {
        "KernelDebugBuild" = true;
        "KernelPrinting" = true;
        "KernelVerificationBuild" = false;
      };
      kernel_options_arch = {
        aarch64 = { };
        riscv64 = { };
      };
    };
    benchmark = {
      debug = false;
      kernel_options = {
        "KernelDebugBuild" = false;
        "KernelVerificationBuild" = false;
        "KernelBenchmarks" = "track_utilisation";
      };
      kernel_options_arch = {
        aarch64 = {
          "KernelArmExportPMUUser" = true;
        };
        riscv64 = { };
      };
    };
  };

  boards = {
    tqma8xqp1gb = {
      arch = "aarch64";
      gcc_cpu = "cortex-a35";
      loader_link_address = "0x80280000";
      kernel_options = {
        "KernelPlatform" = "tqma8xqp1gb";
      };
    };
    zcu102 = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x40000000";
      kernel_options = {
        "KernelPlatform" = "zynqmp";
        "KernelARMPlatform" = "zcu102";
      };
    };
    maaxboard = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x50000000";
      kernel_options = {
        "KernelPlatform" = "maaxboard";
      };
    };
    imx8mm_evk = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x41000000";
      kernel_options = {
        "KernelPlatform" = "imx8mm-evk";
      };
    };
    imx8mp_evk = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x41000000";
      kernel_options = {
        "KernelPlatform" = "imx8mp-evk";
      };
    };
    imx8mq_evk = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x41000000";
      kernel_options = {
        "KernelPlatform" = "imx8mq-evk";
      };
    };
    imx8mp_iotgate = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x50000000";
      kernel_options = {
        "KernelPlatform" = "imx8mp-evk";
        "KernelCustomDTS" = "custom_dts/iot-gate.dts";
        "KernelCustomDTSOverlay" = "src/plat/imx8m-evk/overlay-imx8mp-evk.dts";
      };
    };
    odroidc2 = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x20000000";
      kernel_options = {
        "KernelPlatform" = "odroidc2";
      };
    };
    odroidc4 = {
      arch = "aarch64";
      gcc_cpu = "cortex-a55";
      loader_link_address = "0x20000000";
      kernel_options = {
        "KernelPlatform" = "odroidc4";
      };
    };
    ultra96v2 = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x40000000";
      kernel_options = {
        "KernelPlatform" = "zynqmp";
        "KernelARMPlatform" = "ultra96v2";
      };
    };
    qemu_virt_aarch64 = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x70000000";
      kernel_options = {
        "KernelPlatform" = "qemu-arm-virt";
        "QEMU_MEMORY" = "2048";
        # There is not peripheral timer; so we use the ARM
        # architectural timer
        "KernelArmExportPTMRUser" = true;
      };
    };
    qemu_virt_riscv64 = {
      arch = "riscv64";
      gcc_cpu = "";
      loader_link_address = "0x90000000";
      kernel_options = {
        "KernelPlatform" = "qemu-riscv-virt";
        "QEMU_MEMORY" = "2048";
        "KernelRiscvExtD" = true;
        "KernelRiscvExtF" = true;
      };
    };
    rpi4b_1gb = {
      arch = "aarch64";
      gcc_cpu = "cortex-a72";
      loader_link_address = "0x10000000";
      kernel_options = {
        "KernelPlatform" = "bcm2711";
        "RPI4_MEMORY" = 1024;
      };
    };
    rpi4b_2gb = {
      arch = "aarch64";
      gcc_cpu = "cortex-a72";
      loader_link_address = "0x10000000";
      kernel_options = {
        "KernelPlatform" = "bcm2711";
        "RPI4_MEMORY" = 2048;
      };
    };
    rpi4b_4gb = {
      arch = "aarch64";
      gcc_cpu = "cortex-a72";
      loader_link_address = "0x10000000";
      kernel_options = {
        "KernelPlatform" = "bcm2711";
        "RPI4_MEMORY" = 4096;
      };
    };
    rpi4b_8gb = {
      arch = "aarch64";
      gcc_cpu = "cortex-a72";
      loader_link_address = "0x10000000";
      kernel_options = {
        "KernelPlatform" = "bcm2711";
        "RPI4_MEMORY" = 8192;
      };
    };
    rockpro64 = {
      arch = "aarch64";
      gcc_cpu = "cortex-a53";
      loader_link_address = "0x30000000";
      kernel_options = {
        "KernelPlatform" = "rockpro64";
      };
    };
    hifive_p550 = {
      arch = "riscv64";
      gcc_cpu = "";
      loader_link_address = "0x90000000";
      kernel_options = {
        "KernelPlatform" = "hifive-p550";
        "KernelRiscvExtD" = true;
        "KernelRiscvExtF" = true;
      };
    };
    star64 = {
      arch = "riscv64";
      gcc_cpu = "";
      loader_link_address = "0x60000000";
      kernel_options = {
        "KernelPlatform" = "star64";
        "KernelRiscvExtD" = true;
        "KernelRiscvExtF" = true;
      };
    };
    ariane = {
      arch = "riscv64";
      gcc_cpu = "";
      loader_link_address = "0x90000000";
      kernel_options = {
        "KernelPlatform" = "ariane";
        "KernelRiscvExtD" = true;
        "KernelRiscvExtF" = true;
      };
    };
    cheshire = {
      arch = "riscv64";
      gcc_cpu = "";
      loader_link_address = "0x90000000";
      kernel_options = {
        "KernelPlatform" = "cheshire";
        "KernelRiscvExtD" = true;
        "KernelRiscvExtF" = true;
      };
    };
  };
in
builtins.mapAttrs (
  board: board_attrs:
  (builtins.mapAttrs (config: conf_attrs: {
    inherit (board_attrs) arch gcc_cpu loader_link_address;
    inherit (conf_attrs) debug;
    stdenv = stdenv_arch.${board_attrs.arch};
    kernel_options =
      default_kernel_options
      // default_kernel_options_arch.${board_attrs.arch}
      // board_attrs.kernel_options
      // conf_attrs.kernel_options
      // conf_attrs.kernel_options_arch.${board_attrs.arch};

  }) configs)
) boards
