package haxepunk.graphics.atlas;

import flash.display.BlendMode;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;

@:allow(haxepunk.graphics.atlas.DrawCommand)
private class RenderData
{
	public function new() {}

	public var tx1:Float = 0;
	public var ty1:Float = 0;
	public var tx2:Float = 0;
	public var ty2:Float = 0;
	public var tx3:Float = 0;
	public var ty3:Float = 0;
	public var uvx1:Float = 0;
	public var uvy1:Float = 0;
	public var uvx2:Float = 0;
	public var uvy2:Float = 0;
	public var uvx3:Float = 0;
	public var uvy3:Float = 0;

	public var red:Float = 0;
	public var blue:Float = 0;
	public var green:Float = 0;
	public var alpha:Float = 0;

	public var x1(get, never):Float;
	public inline function get_x1() return DrawCommandBatch.minOf3(tx1, tx2, tx3);
	public var x2(get, never):Float;
	public inline function get_x2() return DrawCommandBatch.maxOf3(tx1, tx2, tx3);
	public var y1(get, never):Float;
	public inline function get_y1() return DrawCommandBatch.minOf3(ty1, ty2, ty3);
	public var y2(get, never):Float;
	public inline function get_y2() return DrawCommandBatch.maxOf3(ty1, ty2, ty3);

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
	public static function create(texture:BitmapData, smooth:Bool, ?blend:BlendMode)
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
	public var bounds:Rectangle = new Rectangle();

	function new() {}

	public inline function addTriangle(tx1:Float, ty1:Float, uvx1:Float, uvy1:Float, tx2:Float, ty2:Float, uvx2:Float, uvy2:Float, tx3:Float, ty3:Float, uvx3:Float, uvy3:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
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
		bounds.setTo(0, 0, 0, 0);
	}

	var data:RenderData;
	var dataCount:Int = 0;
	var _lastData:RenderData;
	var _prev:DrawCommand;
	var _next:DrawCommand;
}
