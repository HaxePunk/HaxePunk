package haxepunk.input.gamepad;

/**
 * Button layout is based on the XBox controller.
 *
 * @since	4.1.0
 */
@:enum
abstract GamepadButton(Int) from Int to Int
{
	public static var all:Array<GamepadButton> = [BtnA, BtnB, BtnX, BtnY, LeftShoulder, RightShoulder, Back, Start, LeftStick, RightStick, Guide, DpadUp, DpadDown, DpadLeft, DpadRight];

	var BtnA:Int = 0;
	var BtnB:Int = 1;
	var BtnX:Int = 2;
	var BtnY:Int = 3;
	var LeftShoulder:Int = 4;
	var RightShoulder:Int = 5;
	var Back:Int = 6;
	var Start:Int = 7;
	var LeftStick:Int = 8;
	var RightStick:Int = 9;
	var Guide:Int = 10;
	var DpadUp:Int = 11;
	var DpadDown:Int = 12;
	var DpadLeft:Int = 13;
	var DpadRight:Int = 14;

	@:to public function toString():String return switch (this)
	{
		case BtnA: "a";
		case BtnB: "b";
		case BtnX: "x";
		case BtnY: "y";
		case LeftShoulder: "leftshoulder";
		case RightShoulder: "rightshoulder";
		case Back: "back";
		case Start: "start";
		case LeftStick: "leftstick";
		case RightStick: "rightstick";
		case Guide: "guide";
		case DpadUp: "up";
		case DpadDown: "down";
		case DpadLeft: "left";
		case DpadRight: "right";
		default: Std.string(this);
	}
}
