package com.haxepunk.utils;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;

class Platform
{
	static function run()
	{
		if (Context.defined("flash")) {}
		else if (Context.definedValue("openfl") >= "4.0.0" && !Context.defined("draw_tiles"))
		{
			Compiler.define("tile_shader");
		}
		else
		{
			Compiler.define("draw_tiles");
		}
	}
}
#end
