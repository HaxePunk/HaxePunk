package haxepunk.graphics;

import flash.display.Graphics;
import flash.geom.Point;
import haxepunk.HXP;
import haxepunk.Graphic;

/**
 * Special Spritemap object that can display blocks of animated sprites.
 */
class TiledSpritemap extends Spritemap
{
	/**
	 * Constructs the tiled spritemap.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 * @param	width			Width of the block to render.
	 * @param	height			Height of the block to render.
	 * @param	callbackFunc	Optional callback function for animation end.
	 */
	public function new(source:TileType, frameWidth:Int = 0, frameHeight:Int = 0, width:Int = 0, height:Int = 0, callbackFunc:Void -> Void = null)
	{
		_graphics = HXP.sprite.graphics;
		_offsetX = _offsetY = 0;
		_imageWidth = width;
		_imageHeight = height;
		super(source, frameWidth, frameHeight, callbackFunc);
	}

	/** Renders the image. */
	@:dox(hide)
	override public function render(layer:Int, point:Point, camera:Camera)
	{
		// determine drawing location
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;

		// TODO: properly handle flipped tiled spritemaps
		if (flipped) _point.x += _sourceRect.width;
		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY,
			sx = fsx * scale * scaleX,
			sy = fsy * scale * scaleY,
			x = 0.0, y = 0.0;

		while (y < _imageHeight)
		{
			while (x < _imageWidth)
			{
				_region.draw(Math.floor((_point.x + x) * fsx), Math.floor((_point.y + y) * fsy),
					layer, sx * (flipped ? -1 : 1), sy, angle,
					_red, _green, _blue, _alpha);
				x += _sourceRect.width;
			}
			x = 0;
			y += _sourceRect.height;
		}
	}

	/**
	 * The x-offset of the texture.
	 */
	public var offsetX(get, set):Float;
	function get_offsetX():Float return _offsetX;
	function set_offsetX(value:Float):Float
	{
		if (_offsetX == value) return value;
		_offsetX = value;
		updateBuffer();
		return _offsetX;
	}

	/**
	 * The y-offset of the texture.
	 */
	public var offsetY(get, set):Float;
	function get_offsetY():Float return _offsetY;
	function set_offsetY(value:Float):Float
	{
		if (_offsetY == value) return value;
		_offsetY = value;
		updateBuffer();
		return _offsetY;
	}

	/**
	 * Sets the texture offset.
	 * @param	x		The x-offset.
	 * @param	y		The y-offset.
	 */
	public function setOffset(x:Float, y:Float)
	{
		if (_offsetX == x && _offsetY == y) return;
		_offsetX = x;
		_offsetY = y;
		updateBuffer();
	}

	var _graphics:Graphics;
	var _imageWidth:Int;
	var _imageHeight:Int;
	var _offsetX:Float;
	var _offsetY:Float;
}
