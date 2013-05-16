package com.haxepunk.graphics.atlas;

import nme.display.Sprite;

class AtlasLayer
{
	public var sprite:Sprite;
	public var data:Array<Float>;
	public var index:Int;
	public var dirty:Bool;

	public function new()
	{
		sprite = new Sprite();
		data = new Array<Float>();
		prepare();
	}

	public inline function prepare()
	{
		if (index < data.length)
		{
			data.splice(index, data.length - index);
		}
		index = 0; // reset index for next run
		dirty = false;
	}
}