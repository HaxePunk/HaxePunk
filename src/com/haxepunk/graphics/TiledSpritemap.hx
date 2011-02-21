package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.display.Graphics;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;

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
	 * @param	callback		Optional callback function for animation end.
	 */
	public function new(source:BitmapData, frameWidth:Int = 0, frameHeight:Int = 0, width:Int = 0, height:Int = 0, callbackFunc:CallbackFunction = null) 
	{
		_graphics = HXP.sprite.graphics;
		_offsetX = _offsetY = 0;
		_imageWidth = width;
		_imageHeight = height;
		super(source, frameWidth, frameHeight, callbackFunc);
	}
	
	/** @private Creates the buffer. */
	override private function createBuffer() 
	{
		if (_imageWidth == 0) _imageWidth = Std.int(_sourceRect.width);
		if (_imageHeight == 0) _imageHeight = Std.int(_sourceRect.height);
		_buffer = new BitmapData(_imageWidth, _imageHeight, true, 0);
		_bufferRect = _buffer.rect;
	}
	
	/** @private Updates the buffer. */
	override public function updateBuffer(clearBefore:Bool = false) 
	{
		// get position of the current frame
		_rect.x = _rect.width * _frame;
		_rect.y = Std.int(_rect.x / _width) * _rect.height;
		_rect.x %= _width;
		if (_flipped) _rect.x = (_width - _rect.width) - _rect.x;
		
		// render it repeated to the buffer
		var xx:Int = Std.int(_offsetX) % _imageWidth,
			yy:Int = Std.int(_offsetY) % _imageHeight;
		if (xx >= 0) xx -= _imageWidth;
		if (yy >= 0) yy -= _imageHeight;
		HXP.point.x = xx;
		HXP.point.y = yy;
		while (HXP.point.y < _imageHeight)
		{
			while (HXP.point.x < _imageWidth)
			{
				_buffer.copyPixels(_source, _sourceRect, HXP.point);
				HXP.point.x += _sourceRect.width;
			}
			HXP.point.x = xx;
			HXP.point.y += _sourceRect.height;
		}
		
		// tint the buffer
		if (_tint != null) _buffer.colorTransform(_bufferRect, _tint);
	}
	
	/**
	 * The x-offset of the texture.
	 */
	public var offsetX(getOffsetX, setOffsetY):Float;
	private function getOffsetX():Float { return _offsetX; }
	private function setOffsetX(value:Float):Float
	{
		if (_offsetX == value) return value;
		_offsetX = value;
		updateBuffer();
		return _offsetX;
	}
	
	/**
	 * The y-offset of the texture.
	 */
	public var offsetY(getOffsetY, setOffsetY):Float;
	private function getOffsetY():Float { return _offsetY; }
	private function setOffsetY(value:Float):Float
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
	
	private var _graphics:Graphics;
	private var _imageWidth:Int;
	private var _imageHeight:Int;
	private var _offsetX:Float;
	private var _offsetY:Float;
}