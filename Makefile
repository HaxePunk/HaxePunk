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

flash: $(FINAL).swf

$(FINAL).swf: $(ASSETS).swf
	haxe -swf9 $(FINAL).swf -swf-version 10 -main $(MAIN) -cp $(SRC) \
	-swf-header $(WIDTH):$(HEIGHT):30:333333 -swf-lib $(ASSETS).swf \
	-D samhaxe

$(ASSETS).swf:
	samhaxe $(ASSETS).xml $(ASSETS).swf

native: $(FINAL).exe

$(FINAL).exe:
	haxe -cp $(SRC) -main $(MAIN) -lib nme -lib hxcpp --remap flash:nme \
	--remap neko:cpp -cpp cpp

clean:
	rm -f $(ASSETS).swf $(FINAL).swf $(FINAL).exe