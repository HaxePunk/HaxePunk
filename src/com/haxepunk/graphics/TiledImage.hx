package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Rectangle;
import com.haxepunk.HXP;

/**
 * Special Image object that can display blocks of tiles.
 */
class TiledImage extends Image
{
	/**
	 * Constructs the TiledImage.
	 * @param	texture		Source texture.
	 * @param	width		The width of the image (the texture will be drawn to fill this area).
	 * @param	height		The height of the image (the texture will be drawn to fill this area).
	 * @param	clipRect	An optional area of the source texture to use (eg. a tile from a tileset).
	 */
	public function new(texture:Dynamic, width:Int = 0, height:Int = 0, clipRect:Rectangle = null)
	{
		_graphics = HXP.sprite.graphics;
		_offsetX = _offsetY = 0;
		_width = width;
		_height = height;
		super(texture, clipRect);
	}
	
	/** @private Creates the buffer. */
	override private function createBuffer() 
	{
		if (_width == 0) _width = Std.int(_sourceRect.width);
		if (_height == 0) _height = Std.int(_sourceRect.height);
		_buffer = new BitmapData(_width, _height, true, 0);
		_bufferRect = _buffer.rect;
	}
	
	/** @private Updates the buffer. */
	override public function updateBuffer(clearBefore:Bool = false)
	{
		if (_source == null) return;
		if (_texture == null)
		{
			_texture = new BitmapData(Std.int(_sourceRect.width), Std.int(_sourceRect.height), true, 0);
			_texture.copyPixels(_source, _sourceRect, HXP.zero);
		}
		_buffer.fillRect(_bufferRect, 0);
		_graphics.clear();
		if (_offsetX != 0 || _offsetY != 0)
		{
			HXP.matrix.identity();
			HXP.matrix.tx = Math.round(_offsetX);
			HXP.matrix.ty = Math.round(_offsetY);
			_graphics.beginBitmapFill(_texture, HXP.matrix);
		}
		else _graphics.beginBitmapFill(_texture);
		_graphics.drawRect(0, 0, _width, _height);
		_buffer.draw(HXP.sprite, null, _tint);
	}
	
	/**
	 * The x-offset of the texture.
	 */
	public var offsetX(getOffsetX, setOffsetX):Float;
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
	
	// Drawing information.
	private var _graphics:Graphics;
	private var _texture:BitmapData;
	private var _width:Int;
	private var _height:Int;
	private var _offsetX:Float;
	private var _offsetY:Float;
}