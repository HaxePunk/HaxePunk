package haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.HXP;
import haxepunk.Graphic;

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
	 * @param	screenScale	How many screens the backdrop must span (to use with screen scaling)
	 */
	public function new(source:ImageType, repeatX:Bool = true, repeatY:Bool = true, screenScale:Float = 1.)
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

		super(Std.int(HXP.width * (repeatX ? 1 : 0) * screenScale) + _textWidth, Std.int(HXP.height * (repeatY ? 1 : 0) * screenScale) + _textHeight);

		if (blit)
		{
			HXP.rect.x = HXP.rect.y = 0;
			HXP.rect.width = _width;
			HXP.rect.height = _height;
			fillTexture(HXP.rect, _source);
		}
	}

	/** Renders the Backdrop. */
	@:dox(hide)
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		var sx = scale * scaleX * HXP.screen.fullScaleX,
			sy = scale * scaleY * HXP.screen.fullScaleY;

		if (_repeatX)
		{
			_point.x %= _textWidth * sx;
			if (_point.x > 0) _point.x -= _textWidth * sx;
		}

		if (_repeatY)
		{
			_point.y %= _textHeight * sy;
			if (_point.y > 0) _point.y -= _textHeight * sy;
		}

		_x = x; _y = y;
		x = y = 0;
		super.render(target, _point, HXP.zero);
		x = _x; y = _y;
	}

	@:dox(hide)
	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		var sx = scale * scaleX,
			sy = scale * scaleY,
			fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;

		var xi:Int = 1,
			yi:Int = 1;
		if (_repeatX)
		{
			_point.x %= _textWidth * sx * fsx;
			if (_point.x > 0) _point.x -= _textWidth * sx * fsx;
			xi = Std.int(Math.ceil((HXP.screen.width - _point.x) / Std.int(_textWidth * sx * fsx)));
		}
		if (_repeatY)
		{
			_point.y %= _textHeight * sy * fsy;
			if (_point.y > 0) _point.y -= _textHeight * sy * fsy;
			yi = Std.int(Math.ceil((HXP.screen.height - _point.y) / Std.int(_textHeight * sy * fsy)));
		}

		var px:Int = Std.int(_point.x), py:Int = Std.int(_point.y);

		for (y in 0 ... yi)
		{
			for (x in 0 ... xi)
			{
				_region.draw(
					px + x * _textWidth * sx * fsx,
					py + y * _textHeight * sy * fsy,
					layer, sx * fsx, sy * fsy, 0,
					_red, _green, _blue, _alpha
				);
			}
		}
	}

	// Backdrop information.
	var _source:BitmapData;
	var _region:AtlasRegion;
	var _textWidth:Int;
	var _textHeight:Int;
	var _repeatX:Bool;
	var _repeatY:Bool;
	var _x:Float;
	var _y:Float;
}
