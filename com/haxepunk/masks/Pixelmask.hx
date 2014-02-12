package com.haxepunk.masks;

import com.haxepunk.Mask;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;

/**
 * A bitmap mask used for pixel-perfect collision.
 */
class Pixelmask extends Hitbox
{
	/**
	 * Alpha threshold of the bitmap used for collision.
	 */
	public var threshold:Int;

	/**
	 * Constructor.
	 * @param	source		The image to use as a mask.
	 * @param	x			X offset of the mask.
	 * @param	y			Y offset of the mask.
	 */
	public function new(source:Dynamic, x:Int = 0, y:Int = 0)
	{
		super();

		// fetch mask data
		if (Std.is(source, BitmapData)) 
			_data = source;
		else 
			_data = HXP.getBitmap(source);
		
		if (_data == null)
			throw "Invalid Pixelmask source image.";

		threshold = 1;

		_matrix = HXP.matrix;
		_rect = HXP.rect;
		_point = HXP.point;
		_point2 = HXP.point2;

		// set mask properties
		_width = data.width;
		_height = data.height;
		_x = x;
		_y = y;

		// set callback functions
		_check.set(Type.getClassName(Mask), collideMask);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
		_check.set(Type.getClassName(Pixelmask), collidePixelmask);
	}

	/** @private Collide against an Entity. */
	override private function collideMask(other:Mask):Bool
	{
		_point.x = parent.x + _x;
		_point.y = parent.y + _y;
		_rect.x = other.parent.x - other.parent.originX;
		_rect.y = other.parent.y - other.parent.originY;
		_rect.width = other.parent.width;
		_rect.height = other.parent.height;
	#if flash
		return _data.hitTest(_point, threshold, _rect);
	#else
		return Mask.hitTest(_data, _point, threshold, _rect);
	#end
	}

	/** @private Collide against a Hitbox. */
	override private function collideHitbox(other:Hitbox):Bool
	{
		_point.x = parent.x + _x;
		_point.y = parent.y + _y;
		_rect.x = other.parent.x + other._x;
		_rect.y = other.parent.y + other._y;
		_rect.width = other._width;
		_rect.height = other._height;
	#if flash
		return _data.hitTest(_point, threshold, _rect);
	#else
		return Mask.hitTest(_data, _point, threshold, _rect);
	#end
	}

	/** @private Collide against a Pixelmask. */
	private function collidePixelmask(other:Pixelmask):Bool
	{
		_point.x = parent.x + _x;
		_point.y = parent.y + _y;
		_point2.x = other.parent.x + other._x;
		_point2.y = other.parent.y + other._y;
	#if flash
		return _data.hitTest(_point, threshold, other._data, _point2, other.threshold);
	#else
		return Mask.hitTest(_data, _point, threshold, other._data, _point2, other.threshold);
	#end
	}

	/**
	 * Current BitmapData mask.
	 */
	public var data(get, set):BitmapData;
	private function get_data():BitmapData { return _data; }
	private function set_data(value:BitmapData):BitmapData
	{
		_data = value;
		_width = value.width;
		_height = value.height;
		update();
		return _data;
	}

	override public function debugDraw(graphics:Graphics, scaleX:Float, scaleY:Float):Void
	{
		_rect.x = 0;
		_rect.y = 0;
		_rect.width = _data.width;
		_rect.height = _data.height;
		
		if (_debug == null || (_debug.width != _data.width || _debug.height != _data.height)) 
		{
			_debug = new BitmapData(data.width, data.height, true, 0);
		} 
		else 
		{
			_debug.fillRect(_rect, 0x0);
		}
		if (_colorTransform == null) 
		{
			_colorTransform = new ColorTransform(1, 1, 1, 0, 0, 0, 0, 0x20);
		}
		
	#if flash
		_debug.threshold(_data, _rect, HXP.zero, ">=", threshold << 24, 0x400000FF, 0xFF000000);
	#else
		/* don't apply alpha threshold in the debug view on non-Flash 'cause it's slow (just show the bitmapdata)*/
		_debug.draw(_data, null, _colorTransform);
	#end
	
		var sx:Float = scaleX;
		var sy:Float = scaleY;
		
		_matrix.a = sx;
		_matrix.d = sy;
		_matrix.b = _matrix.c = 0;
		_matrix.tx = (parent.x - parent.originX - HXP.camera.x) * sx;
		_matrix.ty = (parent.y - parent.originY - HXP.camera.y) * sy;
		
		graphics.lineStyle();
		graphics.beginBitmapFill(_debug, _matrix);
		graphics.drawRect(_matrix.tx, _matrix.ty, _data.width * sx, _data.height * sy);
		graphics.endFill();
	}
	
	
	// Pixelmask information.
	private var _threshold:Int = 1;
	private var _data:BitmapData;
	private var _debug:BitmapData;
	
	// Global objects.
	private var _matrix:Matrix;
	private var _rect:Rectangle;
	private var _point:Point;
	private var _point2:Point;
	
	// Debug Draw.
	private static var _colorTransform:ColorTransform;
}
