package com.haxepunk.graphics.atlas;

class AtlasRegion
{

	public var rotated:Bool;
	public var width(default, null):Float;
	public var height(default, null):Float;

	public function new(parent:TextureAtlas, tileIndex:Int, width:Float, height:Float)
	{
		this.parent = parent;
		this.tileIndex = tileIndex;
		this.width = width;
		this.height = height;
	}

	/**
	 * Prepares tile data for rendering
	 * @param x the x-axis location to draw the tile
	 * @param y the y-axis location to draw the tile
	 * @param scaleX the scale value for the x-axis
	 * @param scaleY the scale value for the y-axis
	 * @param angle an angle to rotate the tile in degrees
	 * @param red a red tint value
	 * @param green a green tint value
	 * @param blue a blue tint value
	 * @param alpha the tile's opacity
	 */
	public inline function draw(x:Float, y:Float,
		scaleX:Float=1, scaleY:Float=1, angle:Float=0,
		red:Float=1, green:Float=1, blue:Float=1, alpha:Float=1)
	{
		if (rotated) angle = angle - 90;
		parent.prepareTile(tileIndex, x, y, scaleX, scaleY, angle, red, green, blue, alpha);
	}

	public function toString():String
	{
		return "[AtlasRegion " + width + ", " + height + " " + tileIndex + "]";
	}

	private var parent:TextureAtlas;
	private var tileIndex:Int;
}