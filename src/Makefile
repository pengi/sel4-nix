ifeq ($(OUT),)
$(error OUT needs to be defined. Call with OUT=<target directory>)
endif

include make/toolchain.mk

# Rapsberry Pi 4 Model B defs
SOC      := bcm2711      # probably not needed
ARCH     := ARMv8M       # probably not needed, or in other format
CPU      := cortex-a72
PLATFORM := rpi4

target:
