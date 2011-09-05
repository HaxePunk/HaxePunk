# Application name
APP = game

# HaxePunk details
MAIN = Main
WIDTH = 640
HEIGHT = 480

# Folders
BIN = bin
SRC = src

# Assets XML filename (for SWF files)
ASSETS = com.haxepunk.debug

#---------------------------------
# Don't change below this point!!
#---------------------------------
FINAL = $(BIN)/$(APP)

all: flash

flash: $(ASSETS).swf
	haxe -swf9 $(FINAL).swf -swf-version 10 -main $(MAIN) -cp $(SRC) \
	-swf-header $(WIDTH):$(HEIGHT):60:000000 -swf-lib $(ASSETS).swf \
	-D samhaxe

$(ASSETS).swf:
	samhaxe $(ASSETS).xml $(ASSETS).swf

native: cpp

cpp:
	haxe -cp $(SRC) -main $(MAIN) -lib nme --remap flash:nme \
	--remap neko:cpp -cpp cpp -D HXCPP_M64

clean:
	rm -f $(ASSETS).swf $(FINAL).swf
	rm -fR cpp