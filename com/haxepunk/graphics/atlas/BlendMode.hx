package com.haxepunk.graphics.atlas;

@:enum
abstract BlendMode(Int) from Int to Int
{
	var Add = 0;
	var Multiply = 9;
	var Normal = 10;
	var Screen = 12;
	var Subtract = 14;

	public var tilesheetBlendFlag(get, never):Int;
	inline function get_tilesheetBlendFlag()
	{
		return switch (this)
		{
			case Add:
				0x00010000;
			default:
				0x00000000;
		}
	}
}
