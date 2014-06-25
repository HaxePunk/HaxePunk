package haxepunk.input;

import lime.ui.MouseEventManager;

import haxepunk.input.Input;

/**
 * The mouse buttons.
 */
@:enum
abstract MouseButton(Int) to Int
{
	var Any = -1;
	var Left = 0;
	var Middle = 3;
	var Right = 6;

	@:op(A+B) private inline function add (rhs:InputValue):Int { return rhs + this; }
	@:op(A<B) private inline function less (rhs:Int):Bool { return this < rhs; }
}

/**
 * Get information on the mouse input.
 */
class Mouse
{
	/** Holds the last mouse buttons pressed */
	public static var last(default, null):MouseButton = MouseButton.Any;

	/** The delta of the mouse wheel, 0 if it wasn't moved this frame */
	public static var wheelDelta(default, null):Float = 0;

	/** X position of the mouse on the screen */
	public static var x(default, null):Float = 0;

	/** Y position of the mouse on the screen */
	public static var y(default, null):Float = 0;

	/**
	 * Returns the name of the mouse button.
	 *
	 * @param button The mouse button to name
	 * @return The name
	 */
	public static function nameOf(button:MouseButton):String
	{
		return switch(button)
		{
			case Any:
				"";

			case Left:
				"Left";

			case Middle:
				"Middle";

			case Right:
				"Right";
		}
	}



	/**
	 * Setup the mouse input support.
	 */
	@:allow(haxepunk.input.Input)
	private static function init():Void
	{
		// Register the events from lime
		MouseEventManager.onMouseMove.add(onMouseMove);
		MouseEventManager.onMouseDown.add(onMouseDown);
		MouseEventManager.onMouseUp.add(onMouseUp);
		MouseEventManager.onMouseWheel.add(onMouseWheel);
	}

	/**
	 * Return the value for a mouse button.
	 *
	 * @param button The mouse button to check
	 * @param v The value to get
	 * @return The value of [v] for [button]
	 */
	@:allow(haxepunk.input.Input)
	private static inline function value(button:MouseButton, v:haxepunk.input.Input.InputValue):Int
	{
		if (button < 0) // Any
		{
			return values[v] + values[v+3] + values[v+6];
		}
		else
		{
			return values[button + v];
		}
	}

	/**
	 * Updates the mouse state.
	 */
	@:allow(haxepunk.input.Input)
	private static function update():Void
	{
		// Was On last frame if was on the previous one and there is at least the same amount of Pressed than Released.
		// Or wasn't On last frame and Pressed > 0
		values[0] = ( (values[0] > 0 && values[1] >= values[2]) || (values[0] == 0 && values[1] > 0) ) ? 1 : 0; // Left
		values[3] = ( (values[3] > 0 && values[4] >= values[5]) || (values[3] == 0 && values[4] > 0) ) ? 1 : 0; // Middle
		values[6] = ( (values[6] > 0 && values[7] >= values[8]) || (values[6] == 0 && values[7] > 0) ) ? 1 : 0; // Right

		// Reset counter for Pressed and Released
		values[1] = values[2] = 0; // Left
		values[4] = values[5] = 0; // Middle
		values[7] = values[8] = 0; // Right

		// Reset wheelDelta
		wheelDelta = 0;
	}

	/**
	 * Lime onMouseMove event.
	 */
	private static function onMouseMove(x:Float, y:Float, button:Int):Void
	{
		Mouse.x = x;
		Mouse.y = y;
	}

	/**
	 * Lime onMouseDown event.
	 */
	private static function onMouseDown(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y, button);

		if (button <= 3) // one of left, middle and right
		{
			values[button*3 + 1] += 1; // pressed value
			untyped last = button*3;
		}
	}

	/**
	 * Lime onMouseUp event.
	 */
	private static function onMouseUp(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y, button);

		if (button <= 3) // one of left, middle and right
		{
			values[button*3 + 2] += 1; // released value
			untyped last = button*3;
		}
	}

	/**
	 * Lime onMouseWheel event.
	 */
	private static function onMouseWheel(deltaX:Float, deltaY:Float):Void
	{
		wheelDelta = deltaX;
	}

	/** Values for On,Pressed,Released for each button */
	private static var values:Array<Int> = [0,0,0, 0,0,0, 0,0,0];
}
