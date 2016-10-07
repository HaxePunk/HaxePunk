package com.haxepunk.masks;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;

/**
 * A bitmap mask used for pixel-perfect collision.
 *
 * Example usage:
 *
 * ```
 * class Object extends Entity
 * {
 *     public function new()
 *     {
 *         super();
 *         var sprite = new Image("myimage.png", 100, 100);
 *         graphic = sprite;
 *         mask = new Imagemask(sprite);
 *     }
 * }
 * ```
 *
 * Remember to call "mask.update()" when you update the image.
 *
 * If you are using `RenderMode.HARDWARE` mode, Imagemask will still work, but only if your
 * Image source is created with a BitmapData. `AtlasData` is not currently
 * supported.
 *
 */
class Imagemask extends Pixelmask
{
	/**
	 * Constructor.
	 * @param source    The image to use as a mask.
	 * @param x     X offset of the mask.
	 * @param y     Y offset of the mask.
	 */
	public function new(source:Image)
	{
		super(new BitmapData(1, 1));
		_class = Type.getClassName(Type.getSuperClass(Type.getClass(this)));
		_source = source;
		update();
		_check.set(Type.getClassName(Imagemask), collidePixelmask);
	}

	/**
	 * Update Source image. Calls update().
	 * @param newsource Update source image.
	 */
	public function setSource(newsource:Image)
	{
		_source = newsource;
		update();
	}

	/**
	 * Updates mask.
	 */
	@:dox(hide)
	override public function update()
	{
		var r = getBounds();

		_x = Math.floor(r.x);
		_y = Math.floor(r.y);
		_width = Math.ceil(r.width);
		_height = Math.ceil(r.height);

		_data = new BitmapData(_width, _height, true, 0x00000000);
		_source.render(_data, new Point(-_x, -_y), new Point(0, 0));

		super.update();
	}

	/**
	 * Calculates the bound box of the source Image, taking account the Image
	 * transformation.
	 * @return  the bound box in local coordinates.
	 */
	public function getBounds():flash.geom.Rectangle
	{
		var sx = _source.scale * _source.scaleX;
		var sy = _source.scale * _source.scaleY;

		var matrix = new Matrix(sx, 0, 0, sy,
			-_source.originX * sx,
			-_source.originY * sy);
		matrix.rotate(_source.angle * HXP.RAD);

		var point = new Point(0, 0);
		var p1 = matrix.transformPoint(point);
		point.x = _source.width;
		point.y = _source.height;
		var p2 = matrix.transformPoint(point);
		point.x = 0;
		point.y = _source.height;
		var p3 = matrix.transformPoint(point);
		point.x = _source.width;
		point.y = 0;
		var p4 = matrix.transformPoint(point);

		var r = new Rectangle(0, 0, 0, 0);
		r.x = Math.min(Math.min(p1.x, p2.x), Math.min(p3.x, p4.x));
		r.y = Math.min(Math.min(p1.y, p2.y), Math.min(p3.y, p4.y));
		r.width  = Math.max(Math.max(p1.x - r.x, p2.x - r.x), Math.max(p3.x - r.x, p4.x - r.x));
		r.height = Math.max(Math.max(p1.y - r.y, p2.y - r.y), Math.max(p3.y - r.y, p4.y - r.y));

		return r;
	}
	
	/** @private Collide against a Pixelmask or an Imagemask. */
	override private function collidePixelmask(other:Pixelmask):Bool
	{
		#if flash
			_point.x = _parent.x + _x;
			_point.y = _parent.y + _y;
			_point2.x = other._parent.x + other._x;
			_point2.y = other._parent.y + other._y;
			return _data.hitTest(_point, threshold, other._data, _point2, other.threshold);
		#else
			var rect = getBounds();
			rect.x += _parent.x;
			rect.y += _parent.y;
			
			if (Std.instance(other, Imagemask) != null) // 'other' inherits from Imagemask
			{
				_rect = cast(other, Imagemask).getBounds();
				_rect.x += other._parent.x;
				_rect.y += other._parent.y;
			}
			else
			{
				_rect.x = other._parent.x + other.x - other._parent.originX;
				_rect.y = other._parent.y + other.y - other._parent.originY;
				_rect.width = other.width;
				_rect.height = other.height;
			}
			
			var intersect = rect.intersection(_rect);

			if (intersect.isEmpty())
			{
				return false;
			}

			for (dx in Math.floor(intersect.x)...Math.floor(intersect.x + intersect.width))
			{
				for (dy in Math.floor(intersect.y)...Math.floor(intersect.y + intersect.height))
				{
					var p1 = (_data.getPixel32(Std.int(dx - rect.x), Std.int(dy - rect.y)) >> 24) & 0xFF;
					var p2 = (other._data.getPixel32(Std.int(dx - _rect.x),
							Std.int(dy - _rect.y)) >> 24) & 0xFF;

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
	 * Current Image mask.
	 */
	private var _source:Image;
}
