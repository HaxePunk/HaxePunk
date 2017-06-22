package haxepunk.graphics.hardware;

import flash.display.BlendMode;
import flash.geom.Rectangle;
import haxepunk.graphics.shader.Shader;
import haxepunk.utils.Color;

@:dox(hide)
class DrawCommandBatch
{
	public static var maxLookbackDrawCalls:Int = 16;
	public static var maxTriangleChecks:Int = 128;

	static var _bounds:Rectangle = new Rectangle();

	public static inline function minOf3(a:Float, b:Float, c:Float) return Math.min(Math.min(a, b), c);
	public static inline function maxOf3(a:Float, b:Float, c:Float) return Math.max(Math.max(a, b), c);

	public var head:DrawCommand;
	var last:DrawCommand;

	public function new() {}

	public inline function recycle()
	{
		if (head != null) head.recycle();
		head = last = null;
	}

	public function getDrawCommand(texture:Texture, shader:Shader, smooth:Bool, blend:BlendMode, clipRect:Rectangle, x1:Float=0, y1:Float=0, x2:Float=0, y2:Float=0, x3:Float=0, y3:Float=0)
	{
		if (blend == null) blend = BlendMode.ALPHA;

		if (last != null && texture != null && last.match(texture, shader, smooth, blend, clipRect))
		{
			// we can reuse the most recent draw call
			return last;
		}
		#if !no_render_batch
		else if (x1 != 0 && y1 != 0 && x2 != 0 && y2 != 0)
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
			while (current != null && i++ < maxLookbackDrawCalls && t < maxTriangleChecks)
			{
				if (current.match(texture, shader, smooth, blend, clipRect))
				{
					found = true;
					break;
				}
				t += current.triangleCount;
				current = current._prev;
			}
			if (found)
			{
				i = t = 0;
				current = last;
				while (current != null && i++ < maxLookbackDrawCalls)
				{
					if (current.match(texture, shader, smooth, blend, clipRect))
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
						while (triangle != null && t++ < maxTriangleChecks)
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
		#end

		var command = DrawCommand.create(texture, shader, smooth, blend, clipRect);
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

	public inline function addRect(
		texture:Texture, shader:Shader,
		smooth:Bool, blend:BlendMode, clipRect:Rectangle,
		rx:Float, ry:Float, rw:Float, rh:Float,
		a:Float, b:Float, c:Float, d:Float,
		tx:Float, ty:Float,
		color:Color, alpha:Float):Void
	{
		if (alpha > 0)
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
				// linear filter requires half pixel offset
				var offset = smooth ? 0.5 : 0;
				uvx1 = (rx + offset) / texture.width;
				uvy1 = (ry + offset) / texture.height;
				uvx2 = (rx + rw - offset) / texture.width;
				uvy2 = (ry + rh - offset) / texture.height;
			}

			// matrix transformations
			var xa = rw * a + tx;
			var yb = rw * b + ty;
			var xc = rh * c + tx;
			var yd = rh * d + ty;

			var command = getDrawCommand(texture, shader, smooth, blend, clipRect);

			command.addTriangle(
				tx, ty, uvx1, uvy1,
				xa, yb, uvx2, uvy1,
				xc, yd, uvx1, uvy2,
				color, alpha
			);

			command.addTriangle(
				xc, yd, uvx1, uvy2,
				xa, yb, uvx2, uvy1,
				xa + rh * c, yb + rh * d, uvx2, uvy2,
				color, alpha
			);
		}
	}

	public inline function addTriangle(texture:Texture, shader:Shader,
		smooth:Bool, blend:BlendMode, clipRect:Rectangle,
		tx1:Float, ty1:Float, uvx1:Float, uvy1:Float,
		tx2:Float, ty2:Float, uvx2:Float, uvy2:Float,
		tx3:Float, ty3:Float, uvx3:Float, uvy3:Float,
		color:Color, alpha:Float):Void
	{
		if (alpha > 0)
		{
			var command = getDrawCommand(texture, shader, smooth, blend, clipRect, tx1, ty1, tx2, ty2, tx3, ty3);
			command.addTriangle(tx1, ty1, uvx1, uvy1, tx2, ty2, uvx2, uvy2, tx3, ty3, uvx3, uvy3, color, alpha);
		}
	}
}
