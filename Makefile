LIME_PATH="$(HOME)/haxe/lib/lime"

.PHONY: all doc haxelib examples unit unit-travis build clean

all: clean unit build examples

tool.n:
	@echo "Compiling tool.n"
	@cd tools && haxe tool.hxml

doc/pages/index.html:
	@echo "Generating documentation"
	@cd doc && \
		haxe doc.hxml && \
		haxelib run dox -i xmls/ -o pages/ -theme theme/ \
			-in com --title "HaxePunk API" \
			-D source-path "https://github.com/HaxePunk/HaxePunk/tree/master" > log.txt || cat log.txt

template.zip:
	@echo "Generating template.zip"
	@cd template && zip -rqX ../template.zip . -x *.DS_Store*

haxepunk.zip: doc/pages/index.html tool.n template.zip
	@echo "Building haxelib project"
	@zip -q haxepunk.zip run.n tool.n haxelib.json README.md include.xml template.zip
	@zip -rq haxepunk.zip com assets doc/pages -x *.DS_Store*

haxelib: haxepunk.zip
	@haxelib local haxepunk.zip > log.txt || cat log.txt

unit: haxelib
	@echo "Running unit tests"
	@cd tests && haxe compile.hxml && neko unit.n

unit-travis:
	# copy ndll to base path
	@cp $(LIME_PATH)/`cat $(LIME_PATH)/.current | sed -e 's/\./,/g'`/legacy/ndll/Linux64/* .
	@make unit # run unit tests

build: haxelib
	@echo "Testing builds on multiple platforms"
	@neko tool.n new build-test > log.txt || cat log.txt
	@echo "Flash..."
	@haxelib run lime build build-test flash
	@echo "Neko..."
	@haxelib run lime build build-test neko
	@echo "Html5..."
	@haxelib run lime build build-test html5
	@rm -rf build-test

examples: haxelib
	@echo "Running example application"
	@cd examples && haxelib run lime test neko -debug

clean:
	@echo "Cleaning up old files"
	@rm -f tool.n haxepunk.zip template.zip doc/xmls/*.xml
	@rm -rf doc/pages/*
