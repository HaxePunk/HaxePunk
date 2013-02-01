package com.haxepunk.graphics;

import nme.display.BitmapData;
import nme.geom.Point;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.AtlasRegion;

/**
 * A background texture that can be repeated horizontally and vertically
 * when drawn. Really useful for parallax backgrounds, textures, etc.
 */
class Backdrop extends Canvas
{
	/**
	 * Constructor.
	 * @param	texture		Source texture.
	 * @param	repeatX		Repeat horizontally.
	 * @param	repeatY		Repeat vertically.
	 */
	public function new(source:Dynamic, repeatX:Bool = true, repeatY:Bool = true)
	{
		if (Std.is(source, BitmapData)) setBitmapSource(source);
		else if (Std.is(source, AtlasRegion)) setAtlasRegion(source);
		else if (Std.is(source, Dynamic)) setBitmapSource(HXP.getBitmap(source));
		if (_source == null && _region == null) setBitmapSource(HXP.createBitmap(HXP.width, HXP.height, true));

		_repeatX = repeatX;
		_repeatY = repeatY;

		super(HXP.width * (repeatX ? 1 : 0) + _textWidth, HXP.height * (repeatY ? 1 : 0) + _textHeight);

		if (_blit)
		{
			HXP.rect.x = HXP.rect.y = 0;
			HXP.rect.width = _width;
			HXP.rect.height = _height;
			fillTexture(HXP.rect, _source);
		}
	}

	private inline function setAtlasRegion(region:AtlasRegion)
	{
		_blit = false;
		_region = region;
		_textWidth = Std.int(region.width);
		_textHeight = Std.int(region.height);
	}

	private inline function setBitmapSource(bitmap:BitmapData)
	{
		_blit = true;
		_source = bitmap;
		_textWidth = _source.width;
		_textHeight = _source.height;
	}

	/** Renders the Backdrop. */
	public override function render(target:BitmapData, point:Point, camera:Point, layer:Int=HXP.BASELAYER)
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		if (_repeatX)
		{
			_point.x %= _textWidth;
			if (_point.x > 0) _point.x -= _textWidth;
		}

		if (_repeatY)
		{
			_point.y %= _textHeight;
			if (_point.y > 0) _point.y -= _textHeight;
		}

		if (_blit)
		{
			_x = x; _y = y;
			x = y = 0;
			super.render(target, _point, HXP.zero);
			x = _x; y = _y;
		}
		else
		{
			var sx = HXP.screen.fullScaleX, sy = HXP.screen.fullScaleY,
				r = HXP.getRed(_color) / 255, g = HXP.getGreen(_color) / 255, b = HXP.getBlue(_color) / 255,
				px = _point.x * sx, py = _point.y * sy;

			var y:Float = 0;
			while (y <= _height * sy)
			{
				var x:Float = 0;
				while (x <= _width * sx)
				{
					_region.draw(px + x, py + y, layer, sx, sy, 0, r, g, b, _alpha);
					x += _textWidth * sx;
				}
				y += _textHeight * sy;
			}
		}
	}

	// Backdrop information.
	private var _source:BitmapData;
	private var _region:AtlasRegion;
	private var _textWidth:Int;
	private var _textHeight:Int;
	private var _repeatX:Bool;
	private var _repeatY:Bool;
	private var _x:Float;
	private var _y:Float;
}