package haxepunk.input;

import flash.ui.Multitouch;
import haxepunk.HXP;
import haxepunk.Signal.Signals;

/**
 * Manage the different inputs.
 */
class Input
{
	static inline var PRESS:String = "press";
	static inline var RELEASE:String = "release";

	/**
	 * Array of currently active InputHandlers.
	 */
	public static var handlers:Array<InputHandler> = [Key, Mouse];

	/**
	 * Returns true if the device supports multi touch
	 */
	public static var multiTouchSupported(default, null):Bool = false;

	static var _signals:Array<String> = new Array();

	/**
	 * Trigger any callbacks meant for this type of input.
	 * @since 4.0.0
	 */
	public static function triggerPress(type:InputType)
	{
		_signals.push(PRESS);
		_signals.push(type);
	}

	/**
	 * Trigger any callbacks meant for this type of input.
	 * @since 4.0.0
	 */
	public static function triggerRelease(type:InputType)
	{
		_signals.push(RELEASE);
		_signals.push(type);
	}

	/**
	 * @deprecated use Key.define
	 */
	public static inline function define(input:InputType, keys:Array<Key>)
	{
		Key.define(input, keys);
	}

	/**
	 * If the input or key is held down.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function check(input:InputType):Bool
	{
		for (handler in handlers)
		{
			if (handler.checkInput(input)) return true;
		}
		return false;
	}

	/**
	 * If the input or key was pressed this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function pressed(input:InputType):Bool
	{
		for (handler in handlers)
		{
			if (handler.pressedInput(input)) return true;
		}
		return false;
	}

	/**
	 * If the input or key was released this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function released(input:InputType):Bool
	{
		for (handler in handlers)
		{
			if (handler.releasedInput(input)) return true;
		}
		return false;
	}

	/**
	 * Enables input handling
	 */
	@:dox(hide)
	public static function enable()
	{
		if (!_enabled && HXP.stage != null)
		{
			Key.init();
			Mouse.init();
			Gamepad.init();

			multiTouchSupported = Multitouch.supportsTouchEvents;
			if (multiTouchSupported)
			{
				Touch.init();
			}
		}
	}

	/**
	 * Updates the input states
	 */
	@:dox(hide)
	public static function update()
	{
		for (handler in handlers) handler.update();
		triggerSignals();
	}

	public static function postUpdate()
	{
		for (handler in handlers) handler.postUpdate();
	}

	static inline function triggerSignals()
	{
		var i:Int = 0;
		while (i < _signals.length)
		{
			var op = _signals[i++],
				type = _signals[i++];
			inline function trigger(signals:Signals)
			{
				if (signals.exists(type)) signals.resolve(type).invoke();
			}
			switch (op)
			{
				case PRESS:
					trigger(HXP.engine.onInputPressed);
					trigger(HXP.scene.onInputPressed);
				case RELEASE:
					trigger(HXP.engine.onInputReleased);
					trigger(HXP.scene.onInputReleased);
				default: {}
			}
		}
		HXP.clear(_signals);
	}

	static var _enabled:Bool = false;
}
