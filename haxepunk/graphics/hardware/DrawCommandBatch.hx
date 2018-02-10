package haxepunk.graphics.hardware;

import haxepunk.utils.BlendMode;
import haxepunk.graphics.shader.Shader;
import haxepunk.utils.Color;
import haxepunk.math.MathUtil;
import haxepunk.math.Rectangle;

class DrawCommandIterator
{
	@:allow(haxepunk.graphics.hardware.DrawCommandBatch)
	var command:DrawCommand = null;
	var current:DrawCommand = null;

	public function new() {}

	public function reset()
	{
		current = command;
	}

	public function hasNext():Bool
	{
		return current != null;
	}

	@:access(haxepunk.graphics.hardware.DrawCommand)
	public function next():DrawCommand
	{
		var result = current;
		current = current._next;
		return result;
	}

	public function recycle()
	{
		if (command != null) command.recycle();
		command = current = null;
	}
}

@:dox(hide)
class DrawCommandBatch
{
	public static var maxTriangleChecks:Int = 128;

	static var _bounds:Rectangle = new Rectangle();

	public var visibleArea:Rectangle = new Rectangle();

	var head = new DrawCommandIterator();
	var last:DrawCommand;

	public function new() {}

	public inline function recycle()
	{
		head.recycle();
		last = null;
	}

	/**
	 * Allows DrawCommandBatch to be used in a for loop.
	 */
	public function iterator():DrawCommandIterator
	{
		head.reset();
		return head;
	}

	public function getDrawCommand(texture:Texture, shader:Shader, smooth:Bool, blend:BlendMode, clipRect:Rectangle, x1:Float=0, y1:Float=0, x2:Float=0, y2:Float=0, x3:Float=0, y3:Float=0, flexibleLayer:Bool=false)
	{
		if (last != null && last.match(texture, shader, smooth, blend, clipRect))
		{
			// we can reuse the most recent draw call
			return last;
		}
		#if !hxp_no_render_batch
		else if ((x1 != 0 || x2 != 0 || x3 != 0) && (y1 != 0 || y2 != 0 || y3 != 0))
		{
			// look back to see if we can add this to a previous draw call
			var t:Int = 0,
				current:DrawCommand = last,
				found:Bool = false;
			while (current != null && t < maxTriangleChecks)
			{
				if (current.match(texture, shader, smooth, blend, clipRect))
				{
					found = true;
					if (flexibleLayer) return current;
					break;
				}
				t += current.triangleCount;
				current = current._prev;
			}
			if (found)
			{
				var rx1 = MathUtil.minOf3(x1, x2, x3),
					rx2 = MathUtil.maxOf3(x1, x2, x3),
					ry1 = MathUtil.minOf3(y1, y2, y3),
					ry2 = MathUtil.maxOf3(y1, y2, y3);
				_bounds.setTo(rx1, ry1, rx2 - rx1, ry2 - ry1);
				t = 0;
				current = last;
				while (current != null)
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
						for (triangle in current.triangles)
						{
							if (t++ >= maxTriangleChecks) break;
							if (triangle.intersectsTriangle(x1, y1, x2, y2, x3, y3))
							{
								collision = true;
								break;
							}
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

		while (last != null && last.data == null)
		{
			// recycle draw commands we didn't actually populate
			var l = last;
			last = last._prev;
			if (last != null) last._next = null;
			l.recycle();
		}

		var command = DrawCommand.create(texture, shader, smooth, blend, clipRect);
		command.visibleArea = this.visibleArea;
		if (last == null)
		{
			head.command = last = command;
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
		color:Color, alpha:Float, flexibleLayer:Bool = false):Void
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
				uvx1 = rx / texture.width;
				uvy1 = ry / texture.height;
				uvx2 = (rx + rw) / texture.width;
				uvy2 = (ry + rh) / texture.height;
			}

			// matrix transformations
			var xa = rw * a + tx;
			var yb = rw * b + ty;
			var xc = rh * c + tx;
			var yd = rh * d + ty;

			var command = getDrawCommand(texture, shader, smooth, blend, clipRect, tx, ty, xa, yb, xc, yd, flexibleLayer);

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
		color:Color, alpha:Float, flexibleLayer:Bool = false):Void
	{
		if (alpha > 0)
		{
			var command = getDrawCommand(texture, shader, smooth, blend, clipRect, tx1, ty1, tx2, ty2, tx3, ty3, flexibleLayer);
			command.addTriangle(tx1, ty1, uvx1, uvy1, tx2, ty2, uvx2, uvy2, tx3, ty3, uvx3, uvy3, color, alpha);
		}
	}
}
