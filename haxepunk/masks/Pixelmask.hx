package haxepunk.masks;

import haxepunk.Mask;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxepunk.HXP;

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
		_check.set(Type.getClassName(Pixelmask), collidePixelmask);
		_check.set(Type.getClassName(Hitbox), collideHitbox);
	}

	/** @private Collide against an Entity. */
	override function collideMask(other:Mask):Bool
	{
		_point.x = _parent.x + _x;
		_point.y = _parent.y + _y;
		_rect.x = other._parent.x - other._parent.originX;
		_rect.y = other._parent.y - other._parent.originY;
		_rect.width = other._parent.width;
		_rect.height = other._parent.height;
		#if flash
		return _data.hitTest(_point, threshold, _rect);
		#else
		_point.x = other._parent.x - other._parent.originX - (_parent.x + _x);
		_point.y = other._parent.y - other._parent.originY - (_parent.y + _y);
		
		var r1 = new Rectangle(0, 0, _data.width, _data.height);
		var r2 = new Rectangle(_point.x, _point.y, other._parent.width, other._parent.height);
		
		var intersect = r1.intersection(r2);
		
		if (intersect.isEmpty())
			return false;
		
		for (dx in Math.floor(intersect.x)...Math.floor(intersect.x + intersect.width + 1))
			for (dy in Math.floor(intersect.y)...Math.floor(intersect.y + intersect.height + 1))
				if ((_data.getPixel32(dx, dy) >> 24) & 0xFF > 0)
					return true;
		
		return false;
		#end
	}

	/** @private Collide against a Hitbox. */
	override function collideHitbox(other:Hitbox):Bool
	{
		_point.x = _parent.x + _x;
		_point.y = _parent.y + _y;
		_rect.x = other._parent.x + other._x;
		_rect.y = other._parent.y + other._y;
		_rect.width = other._width;
		_rect.height = other._height;
		#if flash
		return _data.hitTest(_point, threshold, _rect);
		#else
		_point.x = other._parent.x + other._x - (_parent.x + _x);
		_point.y = other._parent.y + other._y - (_parent.y + _y);
		
		var r1 = new Rectangle(0, 0, _data.width, _data.height);
		var r2 = new Rectangle(_point.x, _point.y, other.width, other.height);
		
		var intersect = r1.intersection(r2);
		
		if (intersect.isEmpty())
			return false;
		
		for (dx in Math.floor(intersect.x)...Math.floor(intersect.x + intersect.width + 1))
			for (dy in Math.floor(intersect.y)...Math.floor(intersect.y + intersect.height + 1))
				if ((_data.getPixel32(dx, dy) >> 24) & 0xFF > 0)
					return true;
		
		return false;
		#end
	}

	/** @private Collide against a Pixelmask. */
	function collidePixelmask(other:Pixelmask):Bool
	{
		#if flash
			_point.x = _parent.x + _x;
			_point.y = _parent.y + _y;
			_point2.x = other._parent.x + other._x;
			_point2.y = other._parent.y + other._y;
			return _data.hitTest(_point, threshold, other._data, _point2, other.threshold);
		#else

			_point.x = other._parent.x + other._x - (_parent.x + _x);
			_point.y = other._parent.y + other._y - (_parent.y + _y);

			var r1 = new Rectangle(0, 0, _data.width, _data.height);
			var r2 = new Rectangle(_point.x, _point.y, other._data.width, other._data.height);

			var intersect = r1.intersection(r2);

			if (intersect.isEmpty())
			{
				return false;
			}

			for (dx in Math.floor(intersect.x)...Math.floor(intersect.x + intersect.width + 1))
			{
				for (dy in Math.floor(intersect.y)...Math.floor(intersect.y + intersect.height + 1))
				{
					var p1 = (_data.getPixel32(dx, dy) >> 24) & 0xFF;
					var p2 = (other._data.getPixel32(Math.floor(dx - _point.x),
							Math.floor(dy - _point.y)) >> 24) & 0xFF;

					if (p1 > 0 && p2 > 0)
					{
						return true;
					}
				}
			}

			return false;
		#end
	}

	/**
	 * Current BitmapData mask.
	 */
	public var data(get, set):BitmapData;
	function get_data():BitmapData return _data; 
	function set_data(value:BitmapData):BitmapData
	{
		_data = value;
		_width = value.width;
		_height = value.height;
		update();
		return _data;
	}

	// Pixelmask information.
	var _data:BitmapData;

	// Global objects.
	var _rect:Rectangle;
	var _point:Point;
	var _point2:Point;
}
