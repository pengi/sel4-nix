ifeq ($(OUT),)
$(error OUT needs to be defined. Call with OUT=<target directory>)
endif

include make/toolchain.mk

# Rapsberry Pi 4 Model B defs
SOC      := bcm2711      # probably not needed
ARCH     := ARMv8M       # probably not needed, or in other format
CPU      := cortex-a72
PLATFORM := rpi4

BOARD           := rpi4b_1gb # rpi4b_8gb
MICROKIT_CONFIG := debug
BUILD_DIR       := build

target: $(OUT)/image.img $(OUT)/image.img.report

SYSTEM=output.system
APPS=$(shell xmllint --xpath '//program_image/@path' $(SYSTEM) | sed 's/^.*="\(.*\)"$$/\1/')

$(OUT)/image.img $(OUT)/image.img.report: $(SYSTEM) $(APPS)
	microkit $(SYSTEM) \
		--board $(BOARD) \
		--search-path $(BUILD_DIR) \
		--config $(MICROKIT_CONFIG) \
		-o $@ \
		-r $@.report


$(BUILD_DIR)/*.elf: *.c
	$(LD) $(LDFLAGS) $^ $(LIBS) -o $@

.PHONY: target