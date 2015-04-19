#!/bin/sh

cp $HOME/haxe/lib/lime/`cat $HOME/haxe/lib/lime/.current | sed -e 's/\./,/g'`/legacy/ndll/Linux64/* .

haxe compile.hxml

neko unit.n
