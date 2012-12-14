package com.haxepunk.graphics.atlas;

class AtlasRegion
{
	public function new(parent:TextureAtlas, tileIndex:Int)
	{
		this.parent = parent;
		this.tileIndex = tileIndex;
	}

	public function draw(x:Float, y:Float, angle:Float)
	{

	}

	private var parent:TextureAtlas;
	private var tileIndex:Int;
}