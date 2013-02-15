package com.haxepunk.graphics;

import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.AtlasRegion;

import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.geom.Point;
import nme.geom.Rectangle;

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
	public function new(source:Dynamic, x:Int = 0, y:Int = 0)
	{
		super();

		// set the origin
		this.x = x;
		this.y = y;

		// set the graphic
		if (Std.is(source, AtlasRegion))
		{
			_blit = false;
			_region = source;
			if (_region == null) throw "Invalid source image.";
			_sourceRect = new Rectangle(0, 0, _region.width, _region.height);
		}
		else if (Std.is(source, BitmapData))
		{
			setBitmapSource(source);
		}
		else
		{
			setBitmapSource(HXP.getBitmap(source));
		}
	}

	private inline function setBitmapSource(bitmap:BitmapData)
	{
		if (bitmap == null) throw "Invalid source image.";
		_blit = true;
		_sourceRect = bitmap.rect;
		_source = bitmap;
	}

	/** @private Renders the Graphic. */
	public override function render(target:BitmapData, point:Point, camera:Point)
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		if (_blit)
		{
			target.copyPixels(_source, _sourceRect, _point, null, null, true);
		}
		else
		{
			var sx = HXP.screen.fullScaleX, sy = HXP.screen.fullScaleY;
			_region.draw(_point.x * sx, _point.y * sy, layer, sx, sy);
		}
	}

	/**
	 * Width of the image.
	 */
	public var width(getWidth, never):Int;
	private function getWidth():Int { return Std.int(_blit ? _source.width : _region.width); }

	/**
	 * Height of the image.
	 */
	public var height(getHeight, never):Int;
	private function getHeight():Int { return Std.int(_blit ? _source.height : _region.height); }

	// Stamp information.
	private var _source:BitmapData;
	private var _sourceRect:Rectangle;
	private var _region:AtlasRegion;
}