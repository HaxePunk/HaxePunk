package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.Point;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;

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
	public function new(texture:Dynamic, repeatX:Bool = true, repeatY:Bool = true) 
	{
		if (Std.is(texture, Dynamic)) _texture = HXP.getBitmap(texture);
		else if (Std.is(texture, BitmapData)) _texture = texture;
		if (_texture == null) _texture = new BitmapData(HXP.width, HXP.height, true, 0);
		
		_repeatX = repeatX;
		_repeatY = repeatY;
		_textWidth = _texture.width;
		_textHeight = _texture.height;
		
		super(HXP.width * (repeatX ? 1 : 0) + _textWidth, HXP.height * (repeatY ? 1 : 0) + _textHeight);
		
		HXP.rect.x = HXP.rect.y = 0;
		HXP.rect.width = _width;
		HXP.rect.height = _height;
		fillTexture(HXP.rect, _texture);
	}
	
	/** Renders the Backdrop. */
	override public function render(target:BitmapData, point:Point, camera:Point) 
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
	
	// Backdrop information.
	private var _texture:BitmapData;
	private var _textWidth:Int;
	private var _textHeight:Int;
	private var _repeatX:Bool;
	private var _repeatY:Bool;
	private var _x:Float;
	private var _y:Float;
}