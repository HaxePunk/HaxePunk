package haxepunk.input;

/**
 * The types of value for an input.
 */
@:enum abstract InputValue(Int)
{
	var On = 0;
	var Pressed = 1;
	var Released = 2;
}

/**
 * Store the values on, pressed and released for a mouse button.
 */
class InputState
{
	public var on:Int = 0;
	public var pressed:Int = 0;
	public var released:Int = 0;

	@:allow(haxepunk.input)
	private function new() { }

	public function value(v:InputValue):Int
	{
		return switch (v)
		{
			case InputValue.On: return on;
			case InputValue.Pressed: return pressed;
			case InputValue.Released: return released;
		};
	}
}
