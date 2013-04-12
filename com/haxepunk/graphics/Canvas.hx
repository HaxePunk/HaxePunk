package com.haxepunk.graphics;

import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.Graphics;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;

/**
 * A  multi-purpose drawing canvas, can be sized beyond the normal Flash BitmapData limits.
 */
class Canvas extends Graphic
{
	/**
	 * Optional blend mode to use (see nme.display.BlendMode for blending modes).
	 */
	public var blend:BlendMode;

	/**
	 * Constructor.
	 * @param	width		Width of the canvas.
	 * @param	height		Height of the canvas.
	 */
	public function new(width:Int, height:Int)
	{
		super();
		_color = 0xFFFFFF;
		_red = _green = _blue = 1;
		_alpha = 1;
		_graphics = HXP.sprite.graphics;
		_matrix = new Matrix();
		_rect = new Rectangle();
		_colorTransform = new ColorTransform();
		_buffers = new Array<BitmapData>();

		_width = width;
		_height = height;
		_refWidth = Math.ceil(width / _maxWidth);
		_refHeight = Math.ceil(height / _maxHeight);
		_ref = HXP.createBitmap(_refWidth, _refHeight);
		var x:Int = 0, y:Int = 0, w:Int, h:Int, i:Int = 0,
			ww:Int = _width % _maxWidth,
			hh:Int = _height % _maxHeight;
		if (ww == 0) ww = _maxWidth;
		if (hh == 0) hh = _maxHeight;
		while (y < _refHeight)
		{
			h = y < _refHeight - 1 ? _maxHeight : hh;
			while (x < _refWidth)
			{
				w = x < _refWidth - 1 ? _maxWidth : ww;
				_ref.setPixel(x, y, i);
				_buffers[i] = HXP.createBitmap(w, h, true);
				i ++; x ++;
			}
			x = 0; y ++;
		}
	}

	/** @private Renders the canvas. */
	override public function render(target:BitmapData, point:Point, camera:Point)
	{
		// determine drawing location
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		// render the buffers
		var xx:Int = 0, yy:Int = 0, buffer:BitmapData, px:Float = _point.x;
		target.lock();
		while (yy < _refHeight)
		{
			while (xx < _refWidth)
			{
				buffer = _buffers[_ref.getPixel(xx, yy)];
				if (_tint != null || blend != null)
				{
					_matrix.tx = _point.x;
					_matrix.ty = _point.y;
					target.draw(buffer, _matrix, _tint, blend);
				}
				else target.copyPixels(buffer, buffer.rect, _point, null, null, true);
				_point.x += _maxWidth;
				xx ++;
			}
			_point.x = px;
			_point.y += _maxHeight;
			xx = 0;
			yy ++;
		}
		target.unlock();
	}

	/**
	 * Draws to the canvas.
	 * @param	x			X position to draw.
	 * @param	y			Y position to draw.
	 * @param	source		Source BitmapData.
	 * @param	rect		Optional area of the source image to draw from. If null, the entire BitmapData will be drawn.
	 */
	public function draw(x:Int, y:Int, source:BitmapData, rect:Rectangle = null)
	{
		var xx:Int = 0, yy:Int = 0;
		for (buffer in _buffers)
		{
			_point.x = x - xx;
			_point.y = y - yy;
			buffer.copyPixels(source, rect != null ? rect : source.rect, _point, null, null, true);
			xx += _maxWidth;
			if (xx >= _width)
			{
				xx = 0;
				yy += _maxHeight;
			}
		}
	}

	/**
	 * Fills the rectangular area of the canvas. The previous contents of that area are completely removed.
	 * @param	rect		Fill rectangle.
	 * @param	color		Fill color.
	 * @param	alpha		Fill alpha.
	 */
	public function fill(rect:Rectangle, color:Int = 0, alpha:Float = 1)
	{
		var xx:Int = 0, yy:Int = 0, buffer:BitmapData;
		_rect.width = rect.width;
		_rect.height = rect.height;
		if (alpha >= 1) color |= 0xFF000000;
		else if (alpha <= 0) color = 0;
		else color = (Std.int(alpha * 255) << 24) | (0xFFFFFF & color);
		for (buffer in _buffers)
		{
			_rect.x = rect.x - xx;
			_rect.y = rect.y - yy;
			buffer.fillRect(_rect, HXP.convertColor(color));
			xx += _maxWidth;
			if (xx >= _width)
			{
				xx = 0;
				yy += _maxHeight;
			}
		}
	}

	/**
	 * Draws over a rectangular area of the canvas.
	 * @param	rect		Drawing rectangle.
	 * @param	color		Draw color.
	 * @param	alpha		Draw alpha. If < 1, this rectangle will blend with existing contents of the canvas.
	 */
	public function drawRect(rect:Rectangle, color:Int = 0, alpha:Float = 1)
	{
		var xx:Int = 0, yy:Int = 0, buffer:BitmapData;
		if (alpha >= 1)
		{
			_rect.width = rect.width;
			_rect.height = rect.height;

			for (buffer in _buffers)
			{
				_rect.x = rect.x - xx;
				_rect.y = rect.y - yy;
				buffer.fillRect(_rect, HXP.convertColor(0xFF000000 | color));
				xx += _maxWidth;
				if (xx >= _width)
				{
					xx = 0;
					yy += _maxHeight;
				}
			}
			return;
		}
		for (buffer in _buffers)
		{
			_graphics.clear();
			_graphics.beginFill(color, alpha);
			_graphics.drawRect(rect.x - xx, rect.y - yy, rect.width, rect.height);
			buffer.draw(HXP.sprite);
			xx += _maxWidth;
			if (xx >= _width)
			{
				xx = 0;
				yy += _maxHeight;
			}
		}
		_graphics.endFill();
	}

	/**
	 * Fills the rectangle area of the canvas with the texture.
	 * @param	rect		Fill rectangle.
	 * @param	texture		Fill texture.
	 */
	public function fillTexture(rect:Rectangle, texture:BitmapData)
	{
		var xx:Int = 0, yy:Int = 0;
		for (buffer in _buffers)
		{
			_graphics.clear();
			_graphics.beginBitmapFill(texture);
			_graphics.drawRect(rect.x - xx, rect.y - yy, rect.width, rect.height);
			buffer.draw(HXP.sprite);
			xx += _maxWidth;
			if (xx >= _width)
			{
				xx = 0;
				yy += _maxHeight;
			}
		}
		_graphics.endFill();
	}

	/**
	 * Draws the Graphic object to the canvas.
	 * @param	x			X position to draw.
	 * @param	y			Y position to draw.
	 * @param	source		Graphic to draw.
	 */
	public function drawGraphic(x:Int, y:Int, source:Graphic)
	{
		var xx:Int = 0, yy:Int = 0;
		for (buffer in _buffers)
		{
			_point.x = x - xx;
			_point.y = y - yy;
			source.render(buffer, _point, HXP.zero);
			xx += _maxWidth;
			if (xx >= _width)
			{
				xx = 0;
				yy += _maxHeight;
			}
		}
	}

	/**
	 * The tinted color of the Canvas. Use 0xFFFFFF to draw the it normally.
	 */
	public var color(get_color, set_color):Int;
	private function get_color():Int { return _color; }
	private function set_color(value:Int):Int
	{
		value %= 0xFFFFFF;
		if (_color == value) return _color;
		_color = value;
		_red = HXP.getRed(color) / 255;
		_green = HXP.getGreen(color) / 255;
		_blue = HXP.getBlue(color) / 255;

		if (_alpha == 1 && _color == 0xFFFFFF)
		{
			_tint = null;
			return _color;
		}
		_tint = _colorTransform;
		_tint.redMultiplier = _red;
		_tint.greenMultiplier = _green;
		_tint.blueMultiplier = _blue;
		_tint.alphaMultiplier = _alpha;
		return _color;
	}

	/**
	 * Change the opacity of the Canvas, a value from 0 to 1.
	 */
	public var alpha(get_alpha, set_alpha):Float;
	private function get_alpha():Float { return _alpha; }
	private function set_alpha(value:Float):Float
	{
		if (value < 0) value = 0;
		if (value > 1) value = 1;
		if (_alpha == value) return _alpha;
		_alpha = value;
		if (_alpha == 1 && _color == 0xFFFFFF)
		{
			_tint = null;
			return _alpha;
		}
		_tint = _colorTransform;
		_tint.redMultiplier = _red;
		_tint.greenMultiplier = _green;
		_tint.blueMultiplier = _blue;
		_tint.alphaMultiplier = _alpha;
		return _alpha;
	}

	/**
	 * Shifts the canvas' pixels by the offset.
	 * @param	x	Horizontal shift.
	 * @param	y	Vertical shift.
	 */
	public function shift(x:Int = 0, y:Int = 0)
	{
		drawGraphic(x, y, this);
	}

	/**
	 * Width of the canvas.
	 */
	public var width(get_width, null):Int;
	private function get_width():Int { return _width; }

	/**
	 * Height of the canvas.
	 */
	public var height(get_height, null):Int;
	private function get_height():Int { return _height; }

	// Buffer information.
	private var _buffers:Array<BitmapData>;
	private var _width:Int;
	private var _height:Int;
	private var _maxWidth:Int = 4000;
	private var _maxHeight:Int = 4000;

	// Color tinting information.
	private var _color:Int;
	private var _alpha:Float;
	private var _tint:ColorTransform;
	private var _colorTransform:ColorTransform;
	private var _matrix:Matrix;
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;

	// Canvas reference information.
	private var _ref:BitmapData;
	private var _refWidth:Int;
	private var _refHeight:Int;

	// Global objects.
	private var _rect:Rectangle;
	private var _graphics:Graphics;
}