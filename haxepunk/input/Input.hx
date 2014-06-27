package haxepunk.input;

import haxepunk.input.Keyboard;
import haxepunk.input.Mouse;
import haxepunk.input.InputState;

/**
 * Either enum used by InputType.
 */
private enum EitherInput
{
	String(s:String);
	MouseButton(mb:MouseButton);
	Key(k:Key);
}

/**
 * Represent any of the following types: String, Key, MouseButton, GamepadButton and Gesture.
 */
private abstract InputType(EitherInput)
{
	public inline function new(e:EitherInput) { this = e; }
	public var type(get, never):EitherInput;

	@:to inline function get_type() { return this; }

	@:from static function fromString(s:String) { return new InputType(String(s)); }
	@:from static function fromMouseButton(mb:MouseButton) { return new InputType(MouseButton(mb)); }
	@:from static function fromKey(k:Key) { return new InputType(Key(k)); }
}

/**
 * Manages the Input from Keyboard, Mouse, Touch and Gamepad.
 * Allow to check the state of Key, MouseButton, GamepadButton and Gesture.
 */
class Input
{
	/**
	 * Check if an input is held down.
	 *
	 * @param input An input to check for
	 * @return If [input] is held down
	 */
	public static inline function check(input:InputType):Bool
	{
		return value(input, InputValue.On) > 0 || value(input, InputValue.Pressed) > 0;
	}

	/**
	 * Defines a new input.
	 *
	 * @param name String to map the input to
	 * @param keys The inputs to use for the Input, don't use string in the array
	 * @param merge If the input is already defined merge the arrays instead of replacing it
	 */
	public static function define(name:String, inputs:Array<InputType>, merge:Bool=false):Void
	{
		if (!merge || !_defines.exists(name))
		{
			_defines.set(name, inputs);
		}
		else
		{
			var existing = _defines.get(name);

			for (input in inputs)
			{
				if (existing.indexOf(input) == -1) // Not already in the array
				{
					existing.push(input);
				}
			}

			_defines.set(name, existing);
		}
	}

	/**
	 * How many times an input was pressed this frame.
	 *
	 * @param input An input to check for
	 * @return The number of times [input] was pressed
	 */
	public static inline function pressed(input:InputType):Int
	{
		return value(input, InputValue.Pressed);
	}

	/**
	 * How many times an input was released this frame.
	 *
	 * @param input An input to check for
	 * @return The number of times [input] was released
	 */
	public static inline function released(input:InputType):Int
	{
		return value(input, InputValue.Released);
	}



	/**
	 * Init the input systems.
	 */
	@:allow(haxepunk.Engine)
	private static function init()
	{
		Keyboard.init();
		Mouse.init();
		//Gamepad.init();
		//Touch.init();
	}

	/**
	 * Get a value from an input.
	 *
	 * If [input] is a String returns the sum of the inputs in the define.
	 *
	 * @param input The input to test against
	 * @param v The value to get
	 * @return The value [v] for the input [input]
	 */
	private static function value(input:InputType, v:InputValue):Int
	{
		switch (input.type)
		{
			case String(name):
				if (_defines.exists(name))
				{
					var sum = 0;

					for (i in _defines.get(name))
					{
						sum = sum + subsystemValue(i, v);
					}

					return sum;
				}
				else
				{
					#if debug trace('[Warning] Input has no define of name "$name"'); #end
					return 0;
				}

			default: // not a string
				return subsystemValue(input, v);
		}
	}

	/**
	 * Get a value from an input, ignore string value.
	 *
	 * @param input The input to test against, if it's a String returns 0
	 * @param v The value to get
	 * @return The value [v] for the input [input]
	 */
	private static function subsystemValue(input:InputType, v:InputValue):Int
	{
		return switch (input.type)
		{
			case String(name):
				0; // ignore strings

			case Key(k):
				Keyboard.value(k, v);

			case MouseButton(mb):
				Mouse.value(mb, v);
			/*
			case GamepadButton(gb):
				Gamepad.value(gb, v);

			case Gesture(g):
				Touch.value(g, v);*/
		}
	}

	/**
	 * Update all input subsystems.
	 */
	@:allow(haxepunk.Engine)
	private static function update():Void
	{
		Keyboard.update();
		Mouse.update();
		//Gamepad.update();
		//Touch.update();
	}

	/** Stocks the inputs the user defined using its name as key. */
	private static var _defines = new Map<String, Array<InputType>>();
}
