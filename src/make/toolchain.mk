# Update to be dynamic for multiple targets
TARGET_PREFIX:=aarch64-none-elf-

CC=:$(TARGET_PREFIX)gcc
LD=:$(TARGET_PREFIX)gcc
AS=:$(TARGET_PREFIX)gcc

# Tool should be added to PATH
MICROKIT_TOOL ?= microkit