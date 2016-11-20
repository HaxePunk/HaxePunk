package com.haxepunk.graphics.atlas;

import flash.display.BitmapData;

@:allow(com.haxepunk.graphics.atlas.DrawCommand)
private class QuadData
{
	public function new() {}

	public var rx:Float = 0;
	public var ry:Float = 0;
	public var rw:Float = 0;
	public var rh:Float = 0;
	public var a:Float = 0;
	public var b:Float = 0;
	public var c:Float = 0;
	public var d:Float = 0;
	public var tx:Float = 0;
	public var ty:Float = 0;
	public var red:Float = 0;
	public var blue:Float = 0;
	public var green:Float = 0;
	public var alpha:Float = 0;

	var _next:QuadData;
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

	static var _pool:DrawCommand;
	static var _quadPool:QuadData;

	public var texture:BitmapData;
	public var smooth:Bool = false;
	public var blend:BlendMode = BlendMode.Normal;

	function new() {}

	public function add(rx:Float, ry:Float, rw:Float, rh:Float, a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float, red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		var quad:QuadData;
		if (_quadPool != null)
		{
			quad = _quadPool;
			_quadPool = _quadPool._next;
			quad._next = null;
		}
		else
		{
			quad = new QuadData();
		}
		quad.rx = rx;
		quad.ry = ry;
		quad.rw = rw;
		quad.rh = rh;
		quad.a = a;
		quad.b = b;
		quad.c = c;
		quad.d = d;
		quad.tx = tx;
		quad.ty = ty;
		quad.red = red;
		quad.green = green;
		quad.blue = blue;
		quad.alpha = alpha;

		if (_lastQuad != null)
		{
			_lastQuad._next = quad;
		}
		else
		{
			this.quad = quad;
		}
		_lastQuad = quad;

		++quads;
	}

	public function recycle()
	{
		recycleQuads();
		var command = this;
		while (command._next != null)
		{
			command = command._next;
			command.recycleQuads();
		}
		command._next = _pool;
		_pool = this;
	}

	inline function recycleQuads()
	{
		quads = 0;
		if (_lastQuad != null)
		{
			_lastQuad._next = _quadPool;
			_quadPool = quad;
		}
		quad = _lastQuad = null;
	}

	var quad:QuadData;
	var quads:Int = 0;
	var _lastQuad:QuadData;
	var _next:DrawCommand;
}
