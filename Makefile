LIME_PATH="$(HOME)/haxe/lib/lime"

.PHONY: all doc haxelib examples unit unit-travis build clean

all: clean unit build examples

run.n:
	@echo "Compiling run.n"
	@cd tools && haxe build.hxml > /dev/null

doc/pages/index.html:
	@echo "Generating documentation"
	@cd doc && \
		haxe doc.hxml && \
		haxelib run dox -i xmls/ -o pages/ -theme theme/ \
			-in com --title "HaxePunk API" \
			-D source-path "https://github.com/HaxePunk/HaxePunk/tree/master" > /dev/null

template.zip:
	@cd template && zip -rqX ../template.zip . -x *.DS_Store*

haxepunk.zip: doc/pages/index.html run.n template.zip
	@echo "Building haxelib project"
	@zip -q haxepunk.zip run.n haxelib.json README.md include.xml template.zip
	@zip -rq haxepunk.zip com assets doc/pages -x *.DS_Store*

haxelib: haxepunk.zip
	@haxelib local haxepunk.zip > /dev/null

unit: haxelib
	@echo "Running unit tests"
	@cd tests && haxe compile.hxml && neko unit.n

unit-travis:
	# copy ndll to base path
	@cp $(LIME_PATH)/`cat $(LIME_PATH)/.current | sed -e 's/\./,/g'`/legacy/ndll/Linux64/* .
	@make unit # run unit tests

build: haxelib
	@echo "Testing builds on multiple platforms"
	@haxelib run HaxePunk new build-test > /dev/null
	@cd build-test && \
		lime build flash && \
		lime build neko && \
		lime build html5
	@rm -rf build-test

examples: haxelib
	@echo "Running example application"
	@cd examples && lime test neko -debug

clean:
	@echo "Cleaning up old files"
	@rm -f run.n haxepunk.zip template.zip doc/xmls/*.xml
	@rm -rf doc/pages/*
