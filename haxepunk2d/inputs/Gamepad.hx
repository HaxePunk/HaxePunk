package haxepunk2d.inputs;

/**
 *
 */
class Gamepad
{
	/** If the user has a keyboard available. */
	public static var available(default, null) : Bool;

	/** */
	static var numberConnected:Int;

	/** Determines the joystick's deadZone. Anything under this value will be considered 0 to prevent jitter. */
	var deadZone : Float;

	/** Holds the last button detected. */
	public static var last(default, null):GamepadButton = NONE;

	/** Each axis contained in an array. */
	var axis : Array<Float>;

	/** If the gamepad is connected. */
	var connected : Bool;

	/** A Point containing the gamepad's hat value. */
	var hat : Point;

	/**
	 * Returns the name of the gamepad button.
	 *
	 * Examples:
	 * Gamepad.nameOf(GamepadButton.LEFT);
	 * Gamepad.nameOf(GamepadButton.last);
	 *
	 * @param button The gamepad button to name
	 * @return The name
	 */
	public static function nameOf(button:GamepadButton):String
	{
		if (button < 0) // ANY || NONE
		{
			return "";
		}
		else
		{
			var v:Int = cast button;
			return "BUTTON " + v;
		}
	}
}

/**
 * The gamepad buttons.
 * To be used with Input.define, Input.check, Input.pressed, Input.released and Gamepad.nameOf.
 *
 * Warning: ANY also encompass buttons that aren't listed here, for gamepad with more than 10 buttons.
 */
@:enum abstract GamepadButton(Int) to Int
{
	var NONE = -2;
	var ANY = -1;

	var BUTTON0 = 0;
	var BUTTON1 = 1;
	var BUTTON2 = 2;
	var BUTTON3 = 3;
	var BUTTON4 = 4;
	var BUTTON5 = 5;
	var BUTTON6 = 6;
	var BUTTON7 = 7;
	var BUTTON8 = 8;
	var BUTTON9 = 9;

	@:op(A<B) private inline function less (rhs:Int):Bool { return this < rhs; }
	@:op(A>B) private inline function more (rhs:Int):Bool { return this > rhs; }
}
