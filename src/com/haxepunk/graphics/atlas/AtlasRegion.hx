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

	public inline function draw(x:Float, y:Float, scale:Float=0, angle:Float=0, color:Int=0xFFFFFFFF)
	{
		parent.prepareTile(tileIndex, x, y, scale, angle, color);
	}

	private var parent:TextureAtlas;
	private var tileIndex:Int;
}