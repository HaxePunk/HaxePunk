package haxepunk.math;

class Rectangle
{

	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;

	public function new(x:Float=0, y:Float=0, width:Float=0, height:Float=0)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public var left(get, set):Float;
	private inline function get_left():Float { return x; }
	private inline function set_left(value:Float):Float { return x = value; }

	public var right(get, set):Float;
	private inline function get_right():Float { return x + width; }
	private inline function set_right(value:Float):Float {
		if (value < x) value = x;
		width = value - x;
		return value;
	}

	public var top(get, set):Float;
	private inline function get_top():Float { return y; }
	private inline function set_top(value:Float):Float { return y = value; }

	public var bottom(get, set):Float;
	private inline function get_bottom():Float { return y + height; }
	private inline function set_bottom(value:Float):Float {
		if (value < y) value = y;
		height = value - y;
		return value;
	}

	public var area(get, never):Float;
	private inline function get_area():Float { return width * height; }

}
