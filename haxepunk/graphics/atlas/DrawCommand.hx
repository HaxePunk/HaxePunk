package haxepunk.graphics.atlas;

import haxe.ds.Vector;
import flash.display.BlendMode;
import flash.display.BitmapData;
import flash.geom.Rectangle;

@:allow(haxepunk.graphics.atlas.DrawCommand)
@:allow(haxepunk.graphics.atlas.DrawCommandBatch)
@:allow(haxepunk.graphics.atlas.HardwareRenderer)
private class RenderData
{
	public function new() {}

	var _data:Vector<Float> = Vector.fromArrayCopy([for (i in 0 ... 16) 0.0]);

	public var tx1(get, set):Float; inline function get_tx1() return _data[0]; inline function set_tx1(v:Float) return _data[0] = v;
	public var ty1(get, set):Float; inline function get_ty1() return _data[1]; inline function set_ty1(v:Float) return _data[1] = v;
	public var uvx1(get, set):Float; inline function get_uvx1() return _data[2]; inline function set_uvx1(v:Float) return _data[2] = v;
	public var uvy1(get, set):Float; inline function get_uvy1() return _data[3]; inline function set_uvy1(v:Float) return _data[3] = v;
	public var tx2(get, set):Float; inline function get_tx2() return _data[4]; inline function set_tx2(v:Float) return _data[4] = v;
	public var ty2(get, set):Float; inline function get_ty2() return _data[5]; inline function set_ty2(v:Float) return _data[5] = v;
	public var uvx2(get, set):Float; inline function get_uvx2() return _data[6]; inline function set_uvx2(v:Float) return _data[6] = v;
	public var uvy2(get, set):Float; inline function get_uvy2() return _data[7]; inline function set_uvy2(v:Float) return _data[7] = v;
	public var tx3(get, set):Float; inline function get_tx3() return _data[8]; inline function set_tx3(v:Float) return _data[8] = v;
	public var ty3(get, set):Float; inline function get_ty3() return _data[9]; inline function set_ty3(v:Float) return _data[9] = v;
	public var uvx3(get, set):Float; inline function get_uvx3() return _data[10]; inline function set_uvx3(v:Float) return _data[10] = v;
	public var uvy3(get, set):Float; inline function get_uvy3() return _data[11]; inline function set_uvy3(v:Float) return _data[11] = v;
	public var red(get, set):Float; inline function get_red() return _data[12]; inline function set_red(v:Float) return _data[12] = v;
	public var green(get, set):Float; inline function get_green() return _data[13]; inline function set_green(v:Float) return _data[13] = v;
	public var blue(get, set):Float; inline function get_blue() return _data[14]; inline function set_blue(v:Float) return _data[14] = v;
	public var alpha(get, set):Float; inline function get_alpha() return _data[15]; inline function set_alpha(v:Float) return _data[15] = v;

	public var x1(get, never):Float;
	public inline function get_x1() return DrawCommandBatch.minOf3(tx1, tx2, tx3);
	public var x2(get, never):Float;
	public inline function get_x2() return DrawCommandBatch.maxOf3(tx1, tx2, tx3);
	public var y1(get, never):Float;
	public inline function get_y1() return DrawCommandBatch.minOf3(ty1, ty2, ty3);
	public var y2(get, never):Float;
	public inline function get_y2() return DrawCommandBatch.maxOf3(ty1, ty2, ty3);

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

	var _next:RenderData;
}

/**
 * Represents a pending hardware draw call. A single DrawCommand batches render
 * calls for the same texture, target and parameters. Based on work by
 * @Beeblerox.
 */
@:dox(hide)
@:allow(haxepunk.graphics.atlas.DrawCommandBatch)
class DrawCommand
{
	public static function create(texture:BitmapData, smooth:Bool, ?blend:BlendMode, ?clipRect:Rectangle)
	{
		if (blend == null) blend = BlendMode.ALPHA;
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
				cmd.addData(new RenderData());
			}
			cmd.recycle();
		}
		return _pool;
	}

	static var _pool:DrawCommand = _prePopulatePool(32, 4);
	static var _dataPool:RenderData;

	public var texture:BitmapData;
	public var smooth:Bool = false;
	public var blend:BlendMode = BlendMode.ALPHA;
	public var clipRect:Rectangle = null;
	#if render_batch
	public var bounds:Rectangle = new Rectangle();
	#end

	function new() {}

	public inline function match(texture:BitmapData, smooth:Bool, blend:BlendMode, clipRect:Rectangle):Bool
	{
		return this.texture == texture && this.smooth == smooth && this.blend == blend &&
			((this.clipRect == null && clipRect == null) ||
				(this.clipRect != null && clipRect != null &&
				Std.int(this.clipRect.x) == Std.int(clipRect.x) &&
				Std.int(this.clipRect.y) == Std.int(clipRect.y) &&
				Std.int(this.clipRect.width) == Std.int(clipRect.width) &&
				Std.int(this.clipRect.height) == Std.int(clipRect.height)
			));
	}

	public inline function addTriangle(tx1:Float, ty1:Float, uvx1:Float, uvy1:Float, tx2:Float, ty2:Float, uvx2:Float, uvy2:Float, tx3:Float, ty3:Float, uvx3:Float, uvy3:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		if (alpha > 0)
		{
			var data:RenderData = getData();
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
			data.red = red;
			data.green = green;
			data.blue = blue;
			data.alpha = alpha;
			addData(data);
		}
	}

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

	inline function getData():RenderData
	{
		var data:RenderData;
		if (_dataPool != null)
		{
			data = _dataPool;
			_dataPool = _dataPool._next;
			data._next = null;
		}
		else
		{
			data = new RenderData();
		}
		return data;
	}

	inline function addData(data:RenderData):Void
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

		++dataCount;

		#if render_batch
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
		dataCount = 0;
		if (data != null)
		{
			_lastData._next = _dataPool;
			_dataPool = data;
		}
		data = _lastData = null;
		#if render_batch
		bounds.setTo(0, 0, 0, 0);
		#end
	}

	var data:RenderData;
	var dataCount:Int = 0;
	var _lastData:RenderData;
	var _prev:DrawCommand;
	var _next:DrawCommand;
}
