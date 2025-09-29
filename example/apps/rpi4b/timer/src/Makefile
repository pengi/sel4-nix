APP := rpi4b_timer.elf

BUILD_DIR=build
BOARD_DIR := $(MICROKIT_SDK)/board/$(BOARD)/$(CONFIG)
CC := $(TOOLCHAIN)-gcc
LD := $(TOOLCHAIN)-ld

CFLAGS := \
	-mcpu=$(CPU) \
	-mstrict-align \
	-nostdlib \
	-ffreestanding \
	-g \
	-Wall \
	-Wno-array-bounds \
	-Wno-unused-variable \
	-Wno-unused-function \
	-Werror \
	-I$(BOARD_DIR)/include \
	-DBOARD_$(BOARD)

LDFLAGS := \
	-L$(BOARD_DIR)/lib

LIBS := \
	-lmicrokit \
	-Tmicrokit.ld

all: $(BUILD_DIR)/$(APP)

$(BUILD_DIR)/$(APP): $(BUILD_DIR)/app.o
	@mkdir -p $(@D)
	$(LD) $(LDFLAGS) $^ $(LIBS) -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

install:
	mkdir -p $(out)
	cp $(BUILD_DIR)/$(APP) $(out)/

.PHONY: all install