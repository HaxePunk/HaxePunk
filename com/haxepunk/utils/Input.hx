package com.haxepunk.utils;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.ui.Keyboard;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import com.haxepunk.HXP;

#if (cpp || neko)
	#if nme
	import nme.events.JoystickEvent;
	#else
	import openfl.events.JoystickEvent;
	#end
#end

class Input
{

	/**
	 * Contains the string of the last keys pressed
	 */
	public static var keyString:String = "";

	/**
	 * Holds the last key pressed
	 */
	public static var lastKey:Int;

	/**
	 * If the mouse is held down
	 */
	public static var mouseDown:Bool;
	/**
	 * If the mouse is up
	 */
	public static var mouseUp:Bool;
	/**
	 * If the mouse was recently pressed
	 */
	public static var mousePressed:Bool;
	/**
	 * If the mouse was recently released
	 */
	public static var mouseReleased:Bool;
	/**
	 * If the mouse wheel has moved
	 */
	public static var mouseWheel:Bool;

	/**
	 * Returns true if the device supports multi touch
	 */
	public static var multiTouchSupported(default, null):Bool = false;

	/**
	 * If the mouse wheel was moved this frame, this was the delta.
	 */
	public static var mouseWheelDelta(get_mouseWheelDelta, never):Int;
	public static function get_mouseWheelDelta():Int
	{
		if (mouseWheel)
		{
			mouseWheel = false;
			return _mouseWheelDelta;
		}
		return 0;
	}

	/**
	 * X position of the mouse on the screen.
	 */
	public static var mouseX(get_mouseX, never):Int;
	private static function get_mouseX():Int
	{
		return HXP.screen.mouseX;
	}

	/**
	 * Y position of the mouse on the screen.
	 */
	public static var mouseY(get_mouseY, never):Int;
	private static function get_mouseY():Int
	{
		return HXP.screen.mouseY;
	}

	/**
	 * The absolute mouse x position on the screen (unscaled).
	 */
	public static var mouseFlashX(get_mouseFlashX, never):Int;
	private static function get_mouseFlashX():Int
	{
		return Std.int(HXP.stage.mouseX);
	}

	/**
	 * The absolute mouse y position on the screen (unscaled).
	 */
	public static var mouseFlashY(get_mouseFlashY, never):Int;
	private static function get_mouseFlashY():Int
	{
		return Std.int(HXP.stage.mouseY);
	}

	/**
	 * Defines a new input.
	 * @param	name		String to map the input to.
	 * @param	keys		The keys to use for the Input.
	 */
	public static function define(name:String, keys:Array<Int>)
	{
		_control.set(name, keys);
	}

	/**
	 * If the input or key is held down.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function check(input:Dynamic):Bool
	{
		if (Std.is(input, String))
		{
#if debug
			if (!_control.exists(input))
			{
				HXP.log("Input '" + input + "' not defined");
				return false;
			}
#end
			var v:Array<Int> = _control.get(input),
				i:Int = v.length;
			while (i-- > 0)
			{
				if (v[i] < 0)
				{
					if (_keyNum > 0) return true;
					continue;
				}
				if (_key[v[i]] == true) return true;
			}
			return false;
		}
		return input < 0 ? _keyNum > 0 : _key[input];
	}

	/**
	 * If the input or key was pressed this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function pressed(input:Dynamic):Bool
	{
		if (Std.is(input, String) && _control.exists(input))
		{
			var v:Array<Int> = _control.get(input),
				i:Int = v.length;
			while (i-- > 0)
			{
				if ((v[i] < 0) ? _pressNum != 0 : indexOf(_press, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _pressNum != 0 : indexOf(_press, input) >= 0;
	}

	/**
	 * If the input or key was released this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function released(input:Dynamic):Bool
	{
		if (Std.is(input, String))
		{
			var v:Array<Int> = _control.get(input),
				i:Int = v.length;
			while (i-- > 0)
			{
				if ((v[i] < 0) ? _releaseNum != 0 : indexOf(_release, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _releaseNum != 0 : indexOf(_release, input) >= 0;
	}

	public static function touchPoints(touchCallback:Touch->Void)
	{
		for (touch in _touches)
		{
			touchCallback(touch);
		}
	}

#if haxe3
	public static var touches(get_touches, never):Map<Int,Touch>;
	private static inline function get_touches():Map<Int,Touch> { return _touches; }
#else
	public static var touches(get_touches, never):IntHash<Touch>;
	private static inline function get_touches():IntHash<Touch> { return _touches; }
#end

	/**
	 * Copy of Lambda.indexOf for speed/memory reasons
	 * @param	a array to use
	 * @param	v value to find index of
	 * @return	index of value in the array
	 */
	private static function indexOf(a:Array<Int>, v:Int):Int
	{
		var i = 0;
		for( v2 in a ) {
			if( v == v2 )
				return i;
			i++;
		}
		return -1;
	}

	/**
	 * Returns a joystick object (creates one if not connected)
	 * @param  id The id of the joystick, starting with 0
	 * @return    A Joystick object
	 */
	public static function joystick(id:Int):Joystick
	{
		var joy:Joystick = _joysticks.get(id);
		if (joy == null)
		{
			joy = new Joystick();
			_joysticks.set(id, joy);
		}
		return joy;
	}

	/**
	 * Returns the number of connected joysticks
	 */
	public static var joysticks(get_joysticks, never):Int;
	private static function get_joysticks():Int
	{
		var count:Int = 0;
		for (joystick in _joysticks)
		{
			if (joystick.connected)
			{
				count += 1;
			}
		}
		return count;
	}

	/**
	 * Enables input handling
	 */
	public static function enable()
	{
		if (!_enabled && HXP.stage != null)
		{
			HXP.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false,  2);
			HXP.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,  2);
			HXP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false,  2);
			HXP.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false,  2);
			HXP.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false,  2);

			multiTouchSupported = Multitouch.supportsTouchEvents;
			if (multiTouchSupported)
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

				HXP.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				HXP.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				HXP.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			}

#if ((nme || openfl) && (cpp || neko))
			HXP.stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoyAxisMove);
			HXP.stage.addEventListener(JoystickEvent.BALL_MOVE, onJoyBallMove);
			HXP.stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoyButtonDown);
			HXP.stage.addEventListener(JoystickEvent.BUTTON_UP, onJoyButtonUp);
			HXP.stage.addEventListener(JoystickEvent.HAT_MOVE, onJoyHatMove);
#end
		}
	}

	/**
	 * Updates the input states
	 */
	public static function update()
	{
		while (_pressNum-- > -1) _press[_pressNum] = -1;
		_pressNum = 0;
		while (_releaseNum-- > -1) _release[_releaseNum] = -1;
		_releaseNum = 0;
		if (mousePressed) mousePressed = false;
		if (mouseReleased) mouseReleased = false;
#if ((nme || openfl) && (cpp || neko))
		for (joystick in _joysticks) joystick.update();
#end
		for (touch in _touches) touch.update();
	}

	private static function onKeyDown(e:KeyboardEvent = null)
	{
		var code:Int = lastKey = e.keyCode;

		if (code == Key.BACKSPACE) keyString = keyString.substr(0, keyString.length - 1);
		else if ((code > 47 && code < 58) || (code > 64 && code < 91) || code == 32)
		{
			if (keyString.length > kKeyStringMax) keyString = keyString.substr(1);
			var char:String = String.fromCharCode(code);

			if (e.shiftKey != #if flash Keyboard.capsLock #else check(Key.CAPS_LOCK) #end)
				char = char.toUpperCase();
			else char = char.toLowerCase();

			keyString += char;
		}

		if (!_key[code])
		{
			_key[code] = true;
			_keyNum++;
			_press[_pressNum++] = code;
		}
	}

	private static function onKeyUp(e:KeyboardEvent = null)
	{
		var code:Int = e.keyCode;
		if (_key[code])
		{
			_key[code] = false;
			_keyNum--;
			_release[_releaseNum++] = code;
		}
	}

	private static function onMouseDown(e:MouseEvent)
	{
		if (!mouseDown)
		{
			mouseDown = true;
			mouseUp = false;
			mousePressed = true;
		}
	}

	private static function onMouseUp(e:MouseEvent)
	{
		mouseDown = false;
		mouseUp = true;
		mouseReleased = true;
	}

	private static function onMouseWheel(e:MouseEvent)
	{
		mouseWheel = true;
		_mouseWheelDelta = e.delta;
	}

	private static function onTouchBegin(e:TouchEvent)
	{
		var touchPoint = new Touch(e.stageX / HXP.screen.fullScaleX, e.stageY / HXP.screen.fullScaleY, e.touchPointID);
		_touches.set(e.touchPointID, touchPoint);
		_touchNum += 1;
	}

	private static function onTouchMove(e:TouchEvent)
	{
		var point = _touches.get(e.touchPointID);
		point.x = e.stageX / HXP.screen.fullScaleX;
		point.y = e.stageY / HXP.screen.fullScaleY;
	}

	private static function onTouchEnd(e:TouchEvent)
	{
		_touches.remove(e.touchPointID);
		_touchNum -= 1;
	}

#if ((nme || openfl) && (cpp || neko))

	private static function onJoyAxisMove(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.axis = e.axis;
	}

	private static function onJoyBallMove(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.ball.x = (Math.abs(e.x) < Joystick.deadZone) ? 0 : e.x;
		joy.ball.y = (Math.abs(e.y) < Joystick.deadZone) ? 0 : e.y;
	}

	private static function onJoyButtonDown(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.buttons.set(e.id, BUTTON_PRESSED);
	}

	private static function onJoyButtonUp(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.buttons.set(e.id, BUTTON_OFF);
	}

	private static function onJoyHatMove(e:JoystickEvent)
	{
		var joy:Joystick = joystick(e.device);

		joy.connected = true;
		joy.hat.x = (Math.abs(e.x) < Joystick.deadZone) ? 0 : e.x;
		joy.hat.y = (Math.abs(e.y) < Joystick.deadZone) ? 0 : e.y;
	}

#end

	private static inline var kKeyStringMax = 100;

	private static var _enabled:Bool = false;
	private static var _touchNum:Int = 0;
	private static var _key:Array<Bool> = new Array<Bool>();
	private static var _keyNum:Int = 0;
	private static var _press:Array<Int> = new Array<Int>();
	private static var _pressNum:Int = 0;
	private static var _release:Array<Int> = new Array<Int>();
	private static var _releaseNum:Int = 0;
	private static var _mouseWheelDelta:Int = 0;
#if haxe3
	private static var _touches:Map<Int,Touch> = new Map<Int,Touch>();
	private static var _joysticks:Map<Int,Joystick> = new Map<Int,Joystick>();
	private static var _control:Map<String,Array<Int>> = new Map<String,Array<Int>>();
#else
	private static var _touches:IntHash<Touch> = new IntHash<Touch>();
	private static var _joysticks:IntHash<Joystick> = new IntHash<Joystick>();
	private static var _control:Hash<Array<Int>> = new Hash<Array<Int>>();
#end
}
