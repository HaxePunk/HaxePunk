package com.haxepunk.graphics;

import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.AtlasRegion;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * A simple non-transformed, non-animated graphic.
 */
class Stamp extends Graphic
{
	/**
	 * Constructor.
	 * @param	source		Source image.
	 * @param	x			X offset.
	 * @param	y			Y offset.
	 */
	public function new(source:ImageType, x:Int = 0, y:Int = 0)
	{
		super();

		// set the origin
		this.x = x;
		this.y = y;

		// set the graphic
		switch (source.type)
		{
			case Left(bitmap):
				blit = true;
				_sourceRect = bitmap.rect;
				_source = bitmap;
			case Right(region):
				blit = false;
				_region = region;
				_sourceRect = new Rectangle(0, 0, _region.width, _region.height);
		}
	}

	/** @private Renders the Graphic. */
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		target.copyPixels(_source, _sourceRect, _point, null, null, true);
	}

	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		var sx = HXP.screen.fullScaleX, sy = HXP.screen.fullScaleY;
		_region.draw(Math.floor(_point.x * sx), Math.floor(_point.y * sy), layer, sx, sy);
	}

	/**
	 * Width of the image.
	 */
	public var width(get, never):Int;
	private function get_width():Int { return Std.int(blit ? _source.width : _region.width); }

	/**
	 * Height of the image.
	 */
	public var height(get, never):Int;
	private function get_height():Int { return Std.int(blit ? _source.height : _region.height); }

	// Stamp information.
	private var _source:BitmapData;
	private var _sourceRect:Rectangle;
	private var _region:AtlasRegion;
}
