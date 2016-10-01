LIME_PATH="$(HOME)/haxe/lib/lime"
COMMAND=openfl
TARGET=neko

.PHONY: all doc docs haxelib examples unit unit-travis build clean

all: clean unit docs examples

docs:
	@make doc/pages/index.html

tool.n: tools/tool.hxml $(shell find tools -name '*.hx')
	@echo "Compiling tool.n"
	@cd tools && haxe tool.hxml

doc/pages/index.html: $(shell find . -name '*.hx')
	@echo "Generating documentation"
	@cd doc && \
		rm -rf bin && \
		haxelib run $(COMMAND) build $(TARGET) -xml && \
		haxelib run dox -i `find bin -name 'types.xml'` -o pages/ -theme theme/ \
			-in com --title "HaxePunk" \
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

unit:
	@echo "Running unit tests"
	@cd tests && haxe compile.hxml && neko unit.n

unit-travis:
	# copy ndll to base path
	@cp $(LIME_PATH)/`cat $(LIME_PATH)/.current | sed -e 's/\./,/g'`/legacy/ndll/Linux64/* .
	@make unit # run unit tests

examples: tool.n
	@echo "Building examples with" ${TARGET} "using" ${COMMAND}
	@cd examples && haxelib run ${COMMAND} build ${TARGET}

clean:
	@echo "Cleaning up old files"
	@rm -f tool.n haxepunk.zip template.zip doc/xmls/*.xml
	@rm -rf doc/pages/*
