package haxepunk.graphics.hardware;

import flash.geom.Rectangle;
import haxepunk.graphics.shader.Shader;
import haxepunk.math.MathUtil;
import haxepunk.utils.BlendMode;
import haxepunk.utils.Color;

@:allow(haxepunk.graphics.hardware)
private class DrawTriangle
{
	public function new() {}

	public var tx1:Float = 0;
	public var ty1:Float = 0;
	public var uvx1:Float = 0;
	public var uvy1:Float = 0;
	public var tx2:Float = 0;
	public var ty2:Float = 0;
	public var uvx2:Float = 0;
	public var uvy2:Float = 0;
	public var tx3:Float = 0;
	public var ty3:Float = 0;
	public var uvx3:Float = 0;
	public var uvy3:Float = 0;
	public var color:Color = 0;
	public var alpha:Float = 0;

	public var x1(get, never):Float;
	public inline function get_x1() return MathUtil.minOf3(tx1, tx2, tx3);
	public var x2(get, never):Float;
	public inline function get_x2() return MathUtil.maxOf3(tx1, tx2, tx3);
	public var y1(get, never):Float;
	public inline function get_y1() return MathUtil.minOf3(ty1, ty2, ty3);
	public var y2(get, never):Float;
	public inline function get_y2() return MathUtil.maxOf3(ty1, ty2, ty3);

	public inline function intersectsTriangle(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float):Bool
	{
		return (
			linesIntersect(x1, y1, x2, y2, tx1, ty1, tx2, ty2) ||
			linesIntersect(x2, y2, x3, y3, tx1, ty1, tx2, ty2) ||
			linesIntersect(x1, y1, x3, y3, tx1, ty1, tx2, ty2) ||
			linesIntersect(x1, y1, x2, y2, tx2, ty2, tx3, ty3) ||
			linesIntersect(x2, y2, x3, y3, tx2, ty2, tx3, ty3) ||
			linesIntersect(x1, y1, x3, y3, tx2, ty2, tx3, ty3) ||
			linesIntersect(x1, y1, x2, y2, tx1, ty1, tx3, ty3) ||
			linesIntersect(x2, y2, x3, y3, tx1, ty1, tx3, ty3) ||
			linesIntersect(x1, y1, x3, y3, tx1, ty1, tx3, ty3) ||
			triangleContains(x1, y1, x2, y2, x3, y3, tx1, ty1) ||
			triangleContains(x1, y1, x2, y2, x3, y3, tx2, ty2) ||
			triangleContains(x1, y1, x2, y2, x3, y3, tx3, ty3) ||
			triangleContains(tx1, ty1, tx2, ty2, tx3, ty3, x1, y1) ||
			triangleContains(tx1, ty1, tx2, ty2, tx3, ty3, x2, y2) ||
			triangleContains(tx1, ty1, tx2, ty2, tx3, ty3, x3, y3)
		);
	}

	static inline function linesIntersect(x11:Float, y11:Float, x12:Float, y12:Float, x21:Float, y21:Float, x22:Float, y22:Float):Bool
	{
		var d = ((y22 - y21) * (x12 - x11)) - ((x22 - x21) * (y12 - y11));
		if (d != 0)
		{
			var ua = (((x22 - x21) * (y11 - y21)) - ((y22 - y21) * (x11 - x21))) / d,
				ub = (((x12 - x11) * (y11 - y21)) - ((y12 - y11) * (x11 - x21))) / d;
			if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) d = 0;
		}
		return d == 0;
	}

	static inline function triangleContains(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, px:Float, py:Float)
	{
		var v0x = x3 - x1,
			v0y = y3 - y1,
			v1x = x2 - x1,
			v1y = y2 - y1,
			v2x = px - x1,
			v2y = py - y1;
		var u = cross(v2x, v2y, v0x, v0y),
			v = cross(v1x, v1y, v2x, v2y),
			d = cross(v1x, v1y, v0x, v0y);
		if (d < 0)
		{
			u = -u;
			v = -v;
			d = -d;
		}
		return u >= 0 && v >= 0 && (u + v) <= d;
	}

	static inline function cross(ux:Float, uy:Float, vx:Float, vy:Float):Float return ux * vy - uy * vx;

	var _next:DrawTriangle;
}

class TriangleIterator
{
	var triangle:DrawTriangle = null;

	public function new()
	{

	}

	public inline function reset(triangle:DrawTriangle)
	{
		this.triangle = triangle;
	}

	public inline function hasNext():Bool
	{
		return triangle != null;
	}

	public inline function next():DrawTriangle
	{
		var current = triangle;
		triangle = triangle._next;
		return current;
	}
}

/**
 * Represents a pending hardware draw call. A single DrawCommand batches render
 * calls for the same texture, target and parameters. Based on work by
 * @Beeblerox.
 */
@:dox(hide)
@:allow(haxepunk.graphics.hardware.DrawCommandBatch)
class DrawCommand
{
	public static function create(texture:Texture, shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle)
	{
		var command:DrawCommand;
		if (_pool != null)
		{
			command = _pool;
			_pool = _pool._next;
			command._prev = command._next = null;
		}
		else
		{
			command = new DrawCommand();
		}
		command.shader = shader;
		command.texture = texture;
		command.smooth = smooth;
		command.blend = blend;
		command.clipRect = clipRect;
		return command;
	}

	static function _prePopulatePool(n:Int, m:Int)
	{
		for (i in 0 ... n)
		{
			var cmd = new DrawCommand();
			for (i in 0 ... m)
			{
				cmd.addData(new DrawTriangle());
			}
			cmd.recycle();
		}
		return _pool;
	}

	static var _pool:DrawCommand = _prePopulatePool(32, 4);
	static var _dataPool:DrawTriangle;

	public var shader:Shader;
	public var texture:Texture;
	public var smooth:Bool = false;
	public var blend:BlendMode = BlendMode.Alpha;
	public var clipRect:Rectangle = null;
	#if !no_render_batch
	public var bounds:Rectangle = new Rectangle();
	#end
	public var triangleCount(default, null):Int = 0;

	function new() {}

	/**
	 * Compares values to this draw command to see if they all match. This is used by the batcher to reuse the previous draw command.
	 */
	public inline function match(texture:Texture, shader:Shader, smooth:Bool, blend:BlendMode, clipRect:Rectangle):Bool
	{
		// These conditions are checked as individual if statements
		// to reduce the number of temporary variables created in hxcpp.
		if (this.smooth != smooth) return false;
		else if (this.texture.id != texture.id) return false;
		else if (this.shader.id != shader.id) return false;
		else if (this.blend != blend) return false;
		else
		{
			// It is faster to do a null check once and compare the results.
			var aRectIsNull = this.clipRect == null;
			var bRectIsNull = clipRect == null;
			if (aRectIsNull != bRectIsNull) return false; // one rect is null the other is not
			if (aRectIsNull) return true; // both are null, return true
			else return Std.int(this.clipRect.x) == Std.int(clipRect.x) &&
					Std.int(this.clipRect.y) == Std.int(clipRect.y) &&
					Std.int(this.clipRect.width) == Std.int(clipRect.width) &&
					Std.int(this.clipRect.height) == Std.int(clipRect.height);
		}
	}

	/**
	 * Add a triangle vertices to render.
	 * @param tx[1-3]  Vrtex x coord
	 * @param ty[1-3]  Vertex y coord
	 * @param uvx[1-3] Texture x coord [0-1]
	 * @param uvy[1-3] Texture y coord [0-1]
	 * @param color    Vertex color tint
	 * @param alpha    Vertex alpha value
	 */
	public inline function addTriangle(tx1:Float, ty1:Float, uvx1:Float, uvy1:Float, tx2:Float, ty2:Float, uvx2:Float, uvy2:Float, tx3:Float, ty3:Float, uvx3:Float, uvy3:Float, color:Color, alpha:Float):Void
	{
		if (alpha > 0)
		{
			var data:DrawTriangle = getData();
			data.tx1 = tx1;
			data.ty1 = ty1;
			data.uvx1 = uvx1;
			data.uvy1 = uvy1;
			data.tx2 = tx2;
			data.ty2 = ty2;
			data.uvx2 = uvx2;
			data.uvy2 = uvy2;
			data.tx3 = tx3;
			data.ty3 = ty3;
			data.uvx3 = uvx3;
			data.uvy3 = uvy3;
			data.color = color;
			data.alpha = alpha;
			addData(data);
		}
	}

	/**
	 * Recycles the data for all draw commands following this one.
	 */
	public function recycle()
	{
		recycleData();
		var command = this;
		while (command._next != null)
		{
			command = command._next;
			command.recycleData();
		}
		command._next = _pool;
		_pool = this;
	}

	public var triangles(get, never):TriangleIterator;
	inline function get_triangles():TriangleIterator
	{
		_iterator.reset(data);
		return _iterator;
	}

	inline function getData():DrawTriangle
	{
		var data:DrawTriangle;
		if (_dataPool != null)
		{
			data = _dataPool;
			_dataPool = _dataPool._next;
			data._next = null;
		}
		else
		{
			data = new DrawTriangle();
		}
		return data;
	}

	inline function addData(data:DrawTriangle):Void
	{
		if (this.data == null)
		{
			this.data = data;
		}
		else
		{
			_lastData._next = data;
		}
		_lastData = data;

		++triangleCount;

		#if !no_render_batch
		// update bounds
		var x1 = data.x1, x2 = data.x2, y1 = data.y1, y2 = data.y2;
		if (bounds.width == 0)
		{
			bounds.x = x1;
			bounds.right = x2;
		}
		else
		{
			if (x1 < bounds.left) bounds.left = x1;
			if (x2 > bounds.right) bounds.right = x2;
		}
		if (bounds.height == 0)
		{
			bounds.y = y1;
			bounds.bottom = y2;
		}
		else
		{
			if (y1 < bounds.top) bounds.top = y1;
			if (y2 > bounds.bottom) bounds.bottom = y2;
		}
		#end
	}

	inline function recycleData()
	{
		triangleCount = 0;
		texture = null;
		if (data != null)
		{
			_lastData._next = _dataPool;
			_dataPool = data;
		}
		data = _lastData = null;
		#if !no_render_batch
		bounds.setTo(0, 0, 0, 0);
		#end
	}

	var _iterator = new TriangleIterator();
	var data:DrawTriangle;
	var _lastData:DrawTriangle;
	var _prev:DrawCommand;
	var _next:DrawCommand;
}
