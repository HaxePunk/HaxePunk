package haxepunk.input.gamepad;

/**
 * Button layout is based on the XBox controller.
 *
 * @since	4.1.0
 */
@:enum
abstract GamepadAxis(Int) from Int to Int
{
	public static var all:Array<GamepadAxis> = [LeftTrigger, RightTrigger, LeftX, LeftY, RightX, RightY];

	var LeftTrigger:Int = 2;
	var RightTrigger:Int = 5;
	var LeftX:Int = 0;
	var LeftY:Int = 1;
	var RightX:Int = 3;
	var RightY:Int = 4;

	@:to public function toString():String return switch (this)
	{
		case LeftTrigger: "lefttrigger";
		case RightTrigger: "righttrigger";
		case LeftX: "leftx";
		case LeftY: "lefty";
		case RightX: "rightx";
		case RightY: "righty";
		default: Std.string(this);
	}
}
