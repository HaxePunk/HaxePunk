COMMAND=openfl
TARGET=neko
TEST=openfl4

.PHONY: all doc docs haxelib examples unit test build clean

all: clean unit docs examples

docs:
	@echo "Generating documentation"
	@cd doc && \
		rm -rf bin && \
		haxelib run $(COMMAND) build $(TARGET) -xml && \
		haxelib run dox -i `find bin -name 'types.xml'` -o pages/ -theme theme/ \
			-in com --title "HaxePunk" \
			-D source-path "https://github.com/HaxePunk/HaxePunk/tree/master" > log.txt || cat log.txt

tools: tool.n run.n

tool.n: tools/tool.hxml tools/CLI.hx
	@echo "Compiling tool.n"
	@cd tools && haxe tool.hxml

run.n: tools/run.hxml tools/Run.hx
	@echo "Compiling run.n"
	@cd tools && haxe run.hxml

template.zip:
	@echo "Generating template.zip"
	@cd template && zip -rqX ../template.zip . -x *.DS_Store*

haxepunk.zip: docs tools template.zip
	@echo "Building haxelib project"
	@zip -q haxepunk.zip run.n tool.n haxelib.json README.md include.xml template.zip
	@zip -rq haxepunk.zip com assets doc/pages -x *.DS_Store*

haxelib: haxepunk.zip
	@haxelib local haxepunk.zip > log.txt || cat log.txt

test: unit

unit:
	@echo "Running unit tests"
	@cd tests && haxelib run munit test test-${TEST}.hxml

checkstyle:
	haxelib run checkstyle -c checkstyle.json -s com

examples: tool.n
	@git submodule update --init
	@echo "Building examples with" ${TARGET} "using" ${COMMAND}
	@for path in `find examples -mindepth 1 -maxdepth 1 -type d`; do echo "Building" $$path"..."; (cd $$path; haxelib run ${COMMAND} build ${TARGET}); done

clean:
	@echo "Cleaning up old files"
	@rm -f tool.n haxepunk.zip template.zip doc/xmls/*.xml
	@rm -rf doc/pages/*
