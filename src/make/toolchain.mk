# Update to be dynamic for multiple targets
TOOLCHAIN:=aarch64-none-elf

CC=:$(TOOLCHAIN)-gcc
LD=:$(TOOLCHAIN)-gcc
AS=:$(TOOLCHAIN)-gcc

# Tool should be added to PATH
MICROKIT_TOOL ?= microkit