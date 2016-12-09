package com.haxepunk.graphics.atlas;

import flash.display.BitmapData;
import flash.geom.Matrix;

@:allow(com.haxepunk.graphics.atlas.DrawCommand)
private class RenderData
{
	public function new() {}

	public var rx1:Float = 0;
	public var ry1:Float = 0;
	public var tx1:Float = 0;
	public var ty1:Float = 0;
	public var rx2:Float = 0;
	public var ry2:Float = 0;
	public var tx2:Float = 0;
	public var ty2:Float = 0;
	public var rx3:Float = 0;
	public var ry3:Float = 0;
	public var tx3:Float = 0;
	public var ty3:Float = 0;
	public var red:Float = 0;
	public var blue:Float = 0;
	public var green:Float = 0;
	public var alpha:Float = 0;

	var _next:RenderData;
}

/**
 * Represents a pending hardware draw call. A single DrawCommand batches render
 * calls for the same texture, target and parameters. Based on work by
 * @Beeblerox.
 */
class DrawCommand
{
	public static function create(texture:BitmapData, smooth:Bool, blend:BlendMode)
	{
		var command:DrawCommand;
		if (_pool != null)
		{
			command = _pool;
			_pool = _pool._next;
			command._next = null;
		}
		else
		{
			command = new DrawCommand();
		}
		command.texture = texture;
		command.smooth = smooth;
		command.blend = blend;
		return command;
	}

	static inline function matrixTransformX(m:Matrix, px:Float, py:Float):Float
	{
		return px * m.a + py * m.c + m.tx;
	}

	static inline function matrixTransformY(m:Matrix, px:Float, py:Float):Float
	{
		return px * m.b + py * m.d + m.ty;
	}

	static var _pool:DrawCommand;
	static var _dataPool:RenderData;

	public var texture:BitmapData;
	public var smooth:Bool = false;
	public var blend:BlendMode = BlendMode.Normal;

	function new() {}

	public inline function addTriangle(tx1:Float, ty1:Float, uvx1:Float, uvy1:Float, tx2:Float, ty2:Float, uvx2:Float, uvy2:Float, tx3:Float, ty3:Float, uvx3:Float, uvy3:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		var data:RenderData = getData();
		data.tx1 = tx1;
		data.ty1 = ty1;
		data.rx1 = uvx1;
		data.ry1 = uvy1;
		data.tx2 = tx2;
		data.ty2 = ty2;
		data.rx2 = uvx2;
		data.ry2 = uvy2;
		data.tx3 = tx3;
		data.ty3 = ty3;
		data.rx3 = uvx3;
		data.ry3 = uvy3;
		data.red = red;
		data.green = green;
		data.blue = blue;
		data.alpha = alpha;
		addData(data);
	}

	public inline function addRect(rx:Float, ry:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		var uvx1 = (rx / texture.width),
			uvy1 = (ry / texture.height),
			uvx2 = ((rx + rw) / texture.width),
			uvy2 = ((ry + rh) / texture.height);

		var matrix = HXP.matrix;
		matrix.setTo(a, b, c, d, tx, ty);

		inline function transformX(x, y) return matrixTransformX(matrix, x, y);
		inline function transformY(x, y) return matrixTransformY(matrix, x, y);

		addTriangle(
			transformX(0, 0), transformY(0, 0), uvx1, uvy1,
			transformX(rw, 0), transformY(rw, 0), uvx2, uvy1,
			transformX(0, rh), transformY(0, rh), uvx1, uvy2,
			red, green, blue, alpha
		);

		addTriangle(
			transformX(0, rh), transformY(0, rh), uvx1, uvy2,
			transformX(rw, 0), transformY(rw, 0), uvx2, uvy1,
			transformX(rw, rh), transformY(rw, rh), uvx2, uvy2,
			red, green, blue, alpha
		);
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
	}

	var data:RenderData;
	var dataCount:Int = 0;
	var _lastData:RenderData;
	var _next:DrawCommand;
}
