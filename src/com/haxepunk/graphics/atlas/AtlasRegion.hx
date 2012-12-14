package com.haxepunk.graphics.atlas;

class AtlasRegion
{
	public function new(parent:TextureAtlas, tileIndex:Int)
	{
		this.parent = parent;
		this.tileIndex = tileIndex;
	}

	public function draw(x:Float, y:Float, scale:Float=0, angle:Float=0, color:Int=0xFFFFFFFF)
	{
		parent.prepareTile(tileIndex, x, y, scale, angle, color);
	}

	private var parent:TextureAtlas;
	private var tileIndex:Int;
}