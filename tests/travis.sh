#!/bin/sh

cp ~/haxelib/lime/`cat ~/haxelib/lime/.current | sed -e 's/\./,/g'`/ndll/Linux64/* .

haxe compile.hxml

neko unit.n
