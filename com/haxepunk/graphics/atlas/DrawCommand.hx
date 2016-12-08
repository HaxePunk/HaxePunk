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

	// TODO
	public function addTriangle():Void {}

	public function addRect(rx:Float, ry:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		var uvx1 = (rx / texture.width),
			uvy1 = (ry / texture.height),
			uvx2 = ((rx + rw) / texture.width),
			uvy2 = ((ry + rh) / texture.height);

		var matrix = HXP.matrix;
		matrix.setTo(a, b, c, d, tx, ty);

		inline function transformX(x, y) return matrixTransformX(matrix, x, y);
		inline function transformY(x, y) return matrixTransformY(matrix, x, y);

		var data1:RenderData = getData();
		data1.tx1 = transformX(0, 0);
		data1.ty1 = transformY(0, 0);
		data1.rx1 = uvx1;
		data1.ry1 = uvy1;
		data1.tx2 = transformX(rw, 0);
		data1.ty2 = transformY(rw, 0);
		data1.rx2 = uvx2;
		data1.ry2 = uvy1;
		data1.tx3 = transformX(0, rh);
		data1.ty3 = transformY(0, rh);
		data1.rx3 = uvx1;
		data1.ry3 = uvy2;
		data1.red = red;
		data1.green = green;
		data1.blue = blue;
		data1.alpha = alpha;
		addData(data1);

		var data2:RenderData = getData();
		data2.tx1 = transformX(0, rh);
		data2.ty1 = transformY(0, rh);
		data2.rx1 = uvx1;
		data2.ry1 = uvy2;
		data2.tx2 = transformX(rw, 0);
		data2.ty2 = transformY(rw, 0);
		data2.rx2 = uvx2;
		data2.ry2 = uvy1;
		data2.tx3 = transformX(rw, rh);
		data2.ty3 = transformY(rw, rh);
		data2.rx3 = uvx2;
		data2.ry3 = uvy2;
		data2.red = red;
		data2.green = green;
		data2.blue = blue;
		data2.alpha = alpha;
		addData(data2);
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
