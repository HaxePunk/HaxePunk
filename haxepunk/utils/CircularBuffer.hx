package haxepunk.utils;

import haxe.ds.Vector;

class CircularBuffer<T>
{
	var pos:Int = 0;
	var len:Int = 0;
	var data:Vector<T>;
	var _iterator:CircularBufferIterator<T>;

	public function new(len:Int)
	{
		data = new Vector(len);
		_iterator = new CircularBufferIterator(this);
	}

	public var length(get, never):Int;
	inline function get_length() return len;

	public var maxLength(get, never):Int;
	inline function get_maxLength() return data.length;

	public var first(get, never):Null<T>;
	inline function get_first()
	{
		return len < 1 ? null : data[index(0)];
	}

	public var last(get, never):Null<T>;
	inline function get_last()
	{
		return len < 1 ? null : data[index(len - 1)];
	}

	public inline function push(val:T)
	{
		data[index(len)] = val;
		if (len < data.length) ++len;
		else ++pos;
	}

	public inline function pop():Null<T>
	{
		if (len < 1) return null;
		return data[index(len--)];
	}

	public inline function get(i:Int):Null<T>
	{
		return (i < 0 || i >= len) ? null : data[index(i)];
	}

	public inline function clear()
	{
		pos = len = 0;
	}

	inline function index(i:Int):Int
	{
		return (pos + i) % maxLength;
	}

	public inline function iterator()
	{
		_iterator.reset();
		return _iterator;
	}

	public inline function slice(start:Int)
	{
		_iterator.reset(start);
		return _iterator;
	}
}

private class CircularBufferIterator<T>
{
	var buffer:CircularBuffer<T>;
	var i:Int = 0;

	public function new(buffer:CircularBuffer<T>)
	{
		this.buffer = buffer;
	}

	public inline function reset(i:Int = 0)
	{
		this.i = i;
	}

	public inline function hasNext() return i < buffer.length;

	public inline function next():T return buffer.get(i++);
}
