package haxepunk.input;

import haxepunk.HXP;
import haxepunk.input.Key;
import haxepunk.Signal.Signals;
#if ((cpp || neko) && haxe4)
import sys.thread.Deque;
#elseif cpp
import cpp.vm.Deque;
#elseif neko
import neko.vm.Deque;
#end

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
	public static var handlers:Array<InputHandler> = [Key.Handler, Mouse];

	/**
	 * Returns true if the device supports multi touch
	 */
	public static var multiTouchSupported(default, null):Bool = false;

	#if (cpp || neko)
	static var _signals(get, never):Deque<String>;
	static var __signals:Deque<String>;
	static inline function get__signals()
	{
		if (__signals == null)
		{
			__signals = new Deque();
		}
		return __signals;
	}
	#else
	static var _signals:Array<String> = new Array();
	#end

	static inline function pushSignal(s:String)
	{
		#if (cpp || neko)
		_signals.add(s);
		#else
		_signals.push(s);
		#end
	}

	/**
	 * Trigger any callbacks meant for this type of input.
	 * @since 4.0.0
	 */
	public static function triggerPress(type:InputType)
	{
		pushSignal(PRESS);
		pushSignal(type);
	}

	/**
	 * Trigger any callbacks meant for this type of input.
	 * @since 4.0.0
	 */
	public static function triggerRelease(type:InputType)
	{
		pushSignal(RELEASE);
		pushSignal(type);
	}

	/**
	 * @deprecated use Key.define
	 */
	public static inline function define(input:InputType, keys:Array<KeyCode>)
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
		#if (cpp || neko)
		var op:String;
		while ((op = _signals.pop(false)) != null)
		{
			var type:String = _signals.pop(true);

		#else
		var i:Int = 0;
		while (i < _signals.length)
		{
			var op = _signals[i++],
				type = _signals[i++];

		#end

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
		#if (!(cpp || neko))
		HXP.clear(_signals);
		#end
	}

	static var _enabled:Bool = false;
}
