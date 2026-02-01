#PATH := /bin
TARGET := dwdebug




ifdef WINDIR
BINARY := $(TARGET).exe
else
BINARY := $(TARGET)
endif




ifndef  TOOLCHAIN_DIR

CC = gcc

all: run

run: $(BINARY)
	./$(BINARY)

install:
	cp -p $(BINARY) /usr/local/bin

else

  # set variable TOOLCHAIN_DIR to cross compile
  # example: https://github.com/raspberrypi/tools
  # make TOOLCHAIN_DIR=<tools>/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf
  # this toolchain has package libusb-1.0-0-dev installed, but
  # we need files from the pi package libusb-dev (previous version):
  # /usr/include/usb.h => <toolchain_dir>/arm-linux-gnueabihf/sysroot/usr/include
  # /usr/lib/arm-linux-gnueabihf/libusb.a => <toolchain_dir>/arm-linux-gnueabihf/sysroot/lib
  CC := $(wildcard $(TOOLCHAIN_DIR)/bin/*-gcc)

endif


UNAME_S := $(shell uname -s)

$(BINARY): */*/*.c */*.c Makefile
ifdef WINDIR
	i686-w64-mingw32-gcc -std=gnu99 -Wall -o $(BINARY) -Dwindows src/$(TARGET).c -lKernel32 -lWinmm -lComdlg32 -lWs2_32
endif
ifeq ($(UNAME_S),Darwin)
	$(CC) -std=gnu99 -g -fno-pie -rdynamic -fPIC -Wall -o $(BINARY) src/$(TARGET).c /opt/homebrew/opt/libusb/lib/libusb-1.0.a /opt/homebrew/opt/libusb-compat/lib/libusb.a -I/opt/homebrew/opt/libusb-compat/include -ldl -Wl,-framework,IOKit -Wl,-framework,CoreFoundation -Wl,-framework,Security
endif
ifeq ($(UNAME_S),Linux)
	$(CC) -std=gnu99 -g -fno-pie -rdynamic -fPIC -Wall -o $(BINARY) src/$(TARGET).c -lusb -ldl
endif
	ls -lap $(BINARY)


clean:
	-rm -rf *.o *.map *.list $(BINARY)

