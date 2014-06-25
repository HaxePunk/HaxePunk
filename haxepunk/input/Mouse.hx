package haxepunk.input;

import haxe.ds.IntMap;
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
	var Middle = 1;
	var Right = 2;

	@:op(A<B) private inline function less (rhs:Int):Bool { return this < rhs; }
}

class MouseState
{
	public var on:Int = 0;
	public var pressed:Int = 0;
	public var released:Int = 0;

	public function value(v:haxepunk.input.Input.InputValue):Int
	{
		return switch (v)
		{
			case InputValue.On: return on;
			case InputValue.Pressed: return pressed;
			case InputValue.Released: return released;
			default: return 0;
		};
	}
}

/**
 * Get information on the mouse input.
 */
class Mouse
{
	/** Holds the last mouse buttons pressed */
	public static var lastButton(default, null):MouseButton = MouseButton.Any;

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
			var result = 0;
			for (state in _states)
			{
				result += state.value(v);
			}
			return result;
		}
		else
		{
			return getMouseState(button).value(v);
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
		for (state in _states)
		{
			state.on = ( (state.on > 0 && state.pressed >= state.released) || (state.on == 0 && state.pressed > 0) ) ? 1 : 0;
			state.pressed = 0;
			state.released = 0;
		}

		// Reset wheelDelta
		wheelDelta = 0;
	}

	/**
	 * Lime onMouseMove event.
	 */
	private static inline function onMouseMove(x:Float, y:Float, button:Int):Void
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

		getMouseState(button).pressed += 1; // pressed value
		untyped lastButton = button;
	}

	/**
	 * Lime onMouseUp event.
	 */
	private static function onMouseUp(x:Float, y:Float, button:Int):Void
	{
		onMouseMove(x, y, button);

		getMouseState(button).released += 1; // released value
		untyped lastButton = button;
	}

	/**
	 * Lime onMouseWheel event.
	 */
	private static function onMouseWheel(deltaX:Float, deltaY:Float):Void
	{
		wheelDelta = deltaX;
	}

	/**
	 * Gets a mouse state object
	 */
	private static function getMouseState(button:Int):MouseState
	{
		var state:MouseState;
		if (_states.exists(button))
		{
			state = _states.get(button);
		}
		else
		{
			state = new MouseState();
			_states.set(button, state);
		}
		return state;
	}

	/** states for On,Pressed,Released for each button */
	private static var _states:IntMap<MouseState> = new IntMap<MouseState>();
}
