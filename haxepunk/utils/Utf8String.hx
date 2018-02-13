package haxepunk.utils;

import haxe.Utf8;

/**
 * This abstract exposes a String-like API with UTF8 support.
 */
abstract Utf8String(String) from String to String
{
	public static inline function fromCharCode(unicode:Int):Utf8String
	{
		var u = new Utf8(4);
		u.addChar(unicode);
		return u.toString();
	}

	public var length(get, never):Int;
	inline function get_length()
	{
		return Utf8.length(this);
	}

	public function new(s:String)
	{
		this = s;
	}

	public inline function charAt(pos:Int):Utf8String
	{
		return fromCharCode(charCodeAt(pos));
	}

	public inline function charCodeAt(pos:Int):Int
	{
		return Utf8.charCodeAt(this, pos);
	}

	public inline function substr(pos:Int, ?len:Int):Utf8String
	{
		return Utf8.sub(this, pos, len);
	}

	@:op(A + B) public function concat(rhs:Utf8String):Utf8String
	{
		var buf = new StringBuf();
		buf.add(Std.string(this));
		buf.add(Std.string(rhs));
		return buf.toString();
	}
}
