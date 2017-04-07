package haxepunk.graphics.atlas;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Rectangle;

@:dox(hide)
class DrawCommandBatch
{
	static inline var MAX_LOOKBACK_CALLS:Int = 8;
	static inline var MAX_TRIANGLE_CHECKS:Int = 16;
	static var _bounds:Rectangle = new Rectangle();

	public static inline function minOf3(a:Float, b:Float, c:Float) return Math.min(Math.min(a, b), c);
	public static inline function maxOf3(a:Float, b:Float, c:Float) return Math.max(Math.max(a, b), c);

	static inline function matrixTransformX(m:Matrix, px:Float, py:Float):Float
	{
		return px * m.a + py * m.c + m.tx;
	}

	static inline function matrixTransformY(m:Matrix, px:Float, py:Float):Float
	{
		return px * m.b + py * m.d + m.ty;
	}

	public var head:DrawCommand;
	var last:DrawCommand;

	public function new() {}

	public inline function recycle()
	{
		if (head != null) head.recycle();
		head = last = null;
	}

	public function getDrawCommand(texture:BitmapData, smooth:Bool, blend:BlendMode, ?x1:Float, ?y1:Float, ?x2:Float, ?y2:Float, ?x3:Float, ?y3:Float)
	{
		if (blend == null) blend = BlendMode.ALPHA;

		if (last != null && last.match(texture, smooth, blend))
		{
			// we can reuse the most recent draw call
			return last;
		}
		else if (x1 != null && y1 != null && x2 != null && y2 != null)
		{
			// look back to see if we can add this to a previous draw call
			var rx1 = minOf3(x1, x2, x3),
				rx2 = maxOf3(x1, x2, x3),
				ry1 = minOf3(y1, y2, y3),
				ry2 = maxOf3(y1, y2, y3);
			_bounds.setTo(rx1, ry1, rx2 - rx1, ry2 - ry1);
			var i:Int = 0,
				t:Int = 0,
				current:DrawCommand = last,
				found:Bool = false;
			while (current != null && i++ < MAX_LOOKBACK_CALLS && t < MAX_TRIANGLE_CHECKS)
			{
				if (current.match(texture, smooth, blend))
				{
					found = true;
					break;
				}
				t += current.dataCount;
				current = current._prev;
			}
			if (found)
			{
				i = t = 0;
				current = last;
				while (current != null && i++ < MAX_LOOKBACK_CALLS)
				{
					if (current.match(texture, smooth, blend))
					{
						// we can use this existing draw call
						return current;
					}
					else if (current.bounds.intersects(_bounds))
					{
						// an intermediate draw command may have drawn over this
						// region; let's investigate
						var collision = false;
						var triangle = current.data;
						while (triangle != null && t++ < MAX_TRIANGLE_CHECKS)
						{
							if (triangle.intersectsTriangle(x1, y1, x2, y2, x3, y3))
							{
								collision = true;
								break;
							}
							triangle = triangle._next;
						}
						if (collision)
						{
							break;
						}
					}
					current = current._prev;
				}
			}
		}

		var command = DrawCommand.create(texture, smooth, blend);
		if (last == null)
		{
			head = last = command;
			command._prev = null;
		}
		else
		{
			last._next = command;
			command._prev = last;
			last = command;
		}
		return command;
	}

	public inline function addRect(texture:BitmapData, smooth:Bool, blend:BlendMode, uvx:Float, uvy:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		var uvx1:Float, uvy1:Float, uvx2:Float, uvy2:Float;
		if (texture == null)
		{
			uvx1 = uvy1 = 0;
			uvx2 = rw;
			uvy2 = rh;
		}
		else
		{
			uvx1 = (uvx / texture.width);
			uvy1 = (uvy / texture.height);
			uvx2 = ((uvx + rw) / texture.width);
			uvy2 = ((uvy + rh) / texture.height);
		}

		var matrix = HXP.matrix;
		matrix.setTo(a, b, c, d, tx, ty);

		inline function transformX(x, y) return matrixTransformX(matrix, x, y);
		inline function transformY(x, y) return matrixTransformY(matrix, x, y);

		addTriangle(
			texture, smooth, blend,
			transformX(0, 0), transformY(0, 0), uvx1, uvy1,
			transformX(rw, 0), transformY(rw, 0), uvx2, uvy1,
			transformX(0, rh), transformY(0, rh), uvx1, uvy2,
			red, green, blue, alpha
		);

		addTriangle(
			texture, smooth, blend,
			transformX(0, rh), transformY(0, rh), uvx1, uvy2,
			transformX(rw, 0), transformY(rw, 0), uvx2, uvy1,
			transformX(rw, rh), transformY(rw, rh), uvx2, uvy2,
			red, green, blue, alpha
		);
	}

	public inline function addTriangle(texture:BitmapData, smooth:Bool, blend:BlendMode, tx1:Float, ty1:Float, uvx1:Float, uvy1:Float, tx2:Float, ty2:Float, uvx2:Float, uvy2:Float, tx3:Float, ty3:Float, uvx3:Float, uvy3:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		if (alpha > 0)
		{
			var command = getDrawCommand(texture, smooth, blend, tx1, ty1, tx2, ty2, tx3, ty3);
			command.addTriangle(tx1, ty1, uvx1, uvy1, tx2, ty2, uvx2, uvy2, tx3, ty3, uvx3, uvy3, red, green, blue, alpha);
		}
	}
}
