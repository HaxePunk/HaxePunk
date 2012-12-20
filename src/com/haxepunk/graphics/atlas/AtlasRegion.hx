package com.haxepunk.graphics.atlas;

class AtlasRegion
{

	public var width(default, null):Float;
	public var height(default, null):Float;

	public function new(parent:TextureAtlas, tileIndex:Int, width:Float, height:Float)
	{
		this.parent = parent;
		this.tileIndex = tileIndex;
		this.width = width;
		this.height = height;
	}

	public inline function draw(x:Float, y:Float, scale:Float=1, angle:Float=0, red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1)
	{
		parent.prepareTile(tileIndex, x, y, scale, angle, red, green, blue, alpha);
	}

	private var parent:TextureAtlas;
	private var tileIndex:Int;
}