package com.haxepunk.graphics;

import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.HXP;
import com.haxepunk.RenderMode;

import flash.display.BitmapData;
import flash.geom.Point;

/**
 * A background texture that can be repeated horizontally and vertically
 * when drawn. Really useful for parallax backgrounds, textures, etc.
 */
class Backdrop extends Canvas
{
	/**
	 * Constructor.
	 * @param	source		Source texture.
	 * @param	repeatX		Repeat horizontally.
	 * @param	repeatY		Repeat vertically.
	 */
	public function new(source:ImageType, repeatX:Bool = true, repeatY:Bool = true)
	{
		switch (source.type)
		{
			case Left(bitmap):
				blit = true;
				_source = bitmap;
				_textWidth = _source.width;
				_textHeight = _source.height;
			case Right(region):
				blit = false;
				_region = region;
				_textWidth = Std.int(region.width);
				_textHeight = Std.int(region.height);
		}

		_repeatX = repeatX;
		_repeatY = repeatY;

		super(HXP.width * (repeatX ? 1 : 0) + _textWidth, HXP.height * (repeatY ? 1 : 0) + _textHeight);

		if (blit)
		{
			HXP.rect.x = HXP.rect.y = 0;
			HXP.rect.width = _width;
			HXP.rect.height = _height;
			fillTexture(HXP.rect, _source);
		}
	}

	/** Renders the Backdrop. */
	public override function render(target:BitmapData, point:Point, camera:Point)
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

		_x = x; _y = y;
		x = y = 0;
		super.render(target, _point, HXP.zero);
		x = _x; y = _y;
	}

	public override function renderAtlas(layer:Int, point:Point, camera:Point)
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

		var sx = HXP.screen.fullScaleX, sy = HXP.screen.fullScaleY,
			px = _point.x * sx, py = _point.y * sy;

		var y:Float = 0;
		while (y < _height * sy)
		{
			var x:Float = 0;
			while (x < _width * sx)
			{
				_region.draw(Math.floor(px + x), Math.floor(py + y), layer, sx, sy, 0, _red, _green, _blue, _alpha);
				x += _textWidth * sx;
			}
			y += _textHeight * sy;
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
