package com.haxepunk.utils;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.ui.Keyboard;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import com.haxepunk.HXP;

#if (cpp || neko)
	import openfl.events.JoystickEvent;
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
	 * If the left button mouse is held down
	 */
	public static var mouseDown:Bool;
	/**
	 * If the left button mouse is up
	 */
	public static var mouseUp:Bool;
	/**
	 * If the left button mouse was recently pressed
	 */
	public static var mousePressed:Bool;
	/**
	 * If the left button mouse was recently released
	 */
	public static var mouseReleased:Bool;

#if !js	
	/**
	 * If the right button mouse is held down
	 */
	public static var rightMouseDown:Bool;
	/**
	 * If the right button mouse is up
	 */
	public static var rightMouseUp:Bool;
	/**
	 * If the right button mouse was recently pressed
	 */
	public static var rightMousePressed:Bool;
	/**
	 * If the right button mouse was recently released
	 */
	public static var rightMouseReleased:Bool;
	
	/**
	 * If the middle button mouse is held down
	 */
	public static var middleMouseDown:Bool;
	/**
	 * If the middle button mouse is up
	 */
	public static var middleMouseUp:Bool;
	/**
	 * If the middle button mouse was recently pressed
	 */
	public static var middleMousePressed:Bool;
	/**
	 * If the middle button mouse was recently released
	 */
	public static var middleMouseReleased:Bool;
#end
	
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
				if ((v[i] < 0) ? _pressNum != 0 : HXP.indexOf(_press, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _pressNum != 0 : HXP.indexOf(_press, input) >= 0;
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
				if ((v[i] < 0) ? _releaseNum != 0 : HXP.indexOf(_release, v[i]) >= 0) return true;
			}
			return false;
		}
		return (input < 0) ? _releaseNum != 0 : HXP.indexOf(_release, input) >= 0;
	}

	public static function touchPoints(touchCallback:Touch->Void)
	{
		for (touch in _touches)
		{
			touchCallback(touch);
		}
	}

	public static var touches(get_touches, never):Map<Int,Touch>;
	private static inline function get_touches():Map<Int,Touch> { return _touches; }

	// preventing null-pointer crashes
	private static var _virtualJoystick : Joystick = new Joystick();
	
	/**
	 * Returns a joystick object (creates one if not connected)
	 * @param  id The id of the gamepad, starting with 0 (does not necassarily start from 0 for Ouya controllers)
	 * @return    A Joystick object
	 */
	private static function _joystick(id:Int):Joystick
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
	 * Returns the Joystick object of the gamepad of player number #
	 * @param	playerNumber The number of the player, from 1 up to 4 (in that order). 
	 * @return 	A Joystick object
	 */
	public static function joystick(playerNumber:Int):Joystick
	{
		if (playerNumber < 1 || playerNumber > 4)
		{
			trace("The player number should be between 1, 2, 3 or 4!");
			return virtualJoystick;
		}
		
		var id:Int = 1;
		for (i in _joysticks.keys())
		{
			if (playerNumber==id)
			{
				return _joysticks.get(i);
			}
			
			id ++;
		}
		
		return virtualJoystick;
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
			
		#if !js
			HXP.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown, false, 2);
			HXP.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp, false, 2);
			HXP.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown, false, 2);
			HXP.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp, false, 2);
		#end
		
			multiTouchSupported = Multitouch.supportsTouchEvents;
			if (multiTouchSupported)
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

				HXP.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
				HXP.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
				HXP.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			}

#if (openfl && (cpp || neko))
			HXP.stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoyAxisMove);
			HXP.stage.addEventListener(JoystickEvent.BALL_MOVE, onJoyBallMove);
			HXP.stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoyButtonDown);
			HXP.stage.addEventListener(JoystickEvent.BUTTON_UP, onJoyButtonUp);
			HXP.stage.addEventListener(JoystickEvent.HAT_MOVE, onJoyHatMove);
#end

		#if !(flash || js)
			_nativeCorrection.set("0_64", Key.INSERT);
			_nativeCorrection.set("0_65", Key.END);
			_nativeCorrection.set("0_66", Key.DOWN);	
			_nativeCorrection.set("0_67", Key.PAGE_DOWN);
			_nativeCorrection.set("0_68", Key.LEFT);	
			_nativeCorrection.set("0_69", -1);
			_nativeCorrection.set("0_70", Key.RIGHT);
			_nativeCorrection.set("0_71", Key.HOME);
			_nativeCorrection.set("0_72", Key.UP);
			_nativeCorrection.set("0_73", Key.PAGE_UP);
			_nativeCorrection.set("0_266", Key.DELETE);
			_nativeCorrection.set("123_222", Key.LEFT_SQUARE_BRACKET);
			_nativeCorrection.set("125_187", Key.RIGHT_SQUARE_BRACKET);
			_nativeCorrection.set("126_233", Key.TILDE);
		
			_nativeCorrection.set("0_80", Key.F1);
			_nativeCorrection.set("0_81", Key.F2);
			_nativeCorrection.set("0_82", Key.F3);
			_nativeCorrection.set("0_83", Key.F4);
			_nativeCorrection.set("0_84", Key.F5);
			_nativeCorrection.set("0_85", Key.F6);
			_nativeCorrection.set("0_86", Key.F7);
			_nativeCorrection.set("0_87", Key.F8);
			_nativeCorrection.set("0_88", Key.F9);
			_nativeCorrection.set("0_89", Key.F10);
			_nativeCorrection.set("0_90", Key.F11);
			
			_nativeCorrection.set("48_224", Key.DIGIT_0);
			_nativeCorrection.set("49_38", Key.DIGIT_1);
			_nativeCorrection.set("50_233", Key.DIGIT_2);
			_nativeCorrection.set("51_34", Key.DIGIT_3);
			_nativeCorrection.set("52_222", Key.DIGIT_4);
			_nativeCorrection.set("53_40", Key.DIGIT_5);
			_nativeCorrection.set("54_189", Key.DIGIT_6);
			_nativeCorrection.set("55_232", Key.DIGIT_7);
			_nativeCorrection.set("56_95", Key.DIGIT_8);
			_nativeCorrection.set("57_231", Key.DIGIT_9);
			
			_nativeCorrection.set("48_64", Key.NUMPAD_0);
			_nativeCorrection.set("49_65", Key.NUMPAD_1);
			_nativeCorrection.set("50_66", Key.NUMPAD_2);
			_nativeCorrection.set("51_67", Key.NUMPAD_3);
			_nativeCorrection.set("52_68", Key.NUMPAD_4);
			_nativeCorrection.set("53_69", Key.NUMPAD_5);
			_nativeCorrection.set("54_70", Key.NUMPAD_6);
			_nativeCorrection.set("55_71", Key.NUMPAD_7);
			_nativeCorrection.set("56_72", Key.NUMPAD_8);
			_nativeCorrection.set("57_73", Key.NUMPAD_9);
			_nativeCorrection.set("42_268", Key.NUMPAD_MULTIPLY);
			_nativeCorrection.set("43_270", Key.NUMPAD_ADD);
			//_nativeCorrection.set("", Key.NUMPAD_ENTER);
			_nativeCorrection.set("45_269", Key.NUMPAD_SUBTRACT);
			_nativeCorrection.set("46_266", Key.NUMPAD_DECIMAL); // point
			_nativeCorrection.set("44_266", Key.NUMPAD_DECIMAL); // comma
			_nativeCorrection.set("47_267", Key.NUMPAD_DIVIDE);
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
		
	#if !js
		if (middleMousePressed) middleMousePressed = false;
		if (middleMouseReleased) middleMouseReleased = false;
		if (rightMousePressed) rightMousePressed = false;
		if (rightMouseReleased) rightMouseReleased = false;
	#end
		
#if (openfl && (cpp || neko))
		for (joystick in _joysticks) joystick.update();
#end
		if (multiTouchSupported)
		{
			for (touch in _touches) touch.update();
		}
	}

	private static function onKeyDown(e:KeyboardEvent = null)
	{
		var code:Int = keyCode(e);
		if (code == -1) // No key
			return;
			
		lastKey = code;

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
		var code:Int = keyCode(e);
		if (code == -1) // No key
			return;
		
		if (_key[code])
		{
			_key[code] = false;
			_keyNum--;
			_release[_releaseNum++] = code;
		}
	}
	
	public static function keyCode(e:KeyboardEvent) : Int
	{
	#if (flash || js)
		return e.keyCode;
	#else		
		var code = _nativeCorrection.get(e.charCode + "_" + e.keyCode);
		
		if (code == null)
			return e.keyCode;
		else
			return code;
	#end
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

#if !js
	private static function onMiddleMouseDown(e:MouseEvent)
	{
		if (!middleMouseDown)
		{
			middleMouseDown = true;
			middleMouseUp = false;
			middleMousePressed = true;
		}
	}
	
	private static function onMiddleMouseUp(e:MouseEvent)
	{
		middleMouseDown = false;
		middleMouseUp = true;
		middleMouseReleased = true;
	}
	
	private static function onRightMouseDown(e:MouseEvent)
	{
		if (!rightMouseDown)
		{
			rightMouseDown = true;
			rightMouseUp = false;
			rightMousePressed = true;
		}
	}
	
	private static function onRightMouseUp(e:MouseEvent)
	{
		rightMouseDown = false;
		rightMouseUp = true;
		rightMouseReleased = true;
	}
#end

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

#if (openfl && (cpp || neko))

	private static function onJoyAxisMove(e:JoystickEvent)
	{
		var joy:Joystick = _joystick(e.device);

		joy.connected = true;
		joy.axis = e.axis;
	}

	private static function onJoyBallMove(e:JoystickEvent)
	{
		var joy:Joystick = _joystick(e.device);

		joy.connected = true;
		joy.ball.x = (Math.abs(e.x) < Joystick.deadZone) ? 0 : e.x;
		joy.ball.y = (Math.abs(e.y) < Joystick.deadZone) ? 0 : e.y;
	}

	private static function onJoyButtonDown(e:JoystickEvent)
	{
		var joy:Joystick = _joystick(e.device);

		joy.connected = true;
		joy.buttons.set(e.id, BUTTON_PRESSED);
	}

	private static function onJoyButtonUp(e:JoystickEvent)
	{
		var joy:Joystick = _joystick(e.device);

		joy.connected = true;
		joy.buttons.set(e.id, BUTTON_OFF);
	}

	private static function onJoyHatMove(e:JoystickEvent)
	{
		var joy:Joystick = _joystick(e.device);

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
	private static var _touches:Map<Int,Touch> = new Map<Int,Touch>();
	private static var _joysticks:Map<Int,Joystick> = new Map<Int,Joystick>();
	private static var _control:Map<String,Array<Int>> = new Map<String,Array<Int>>();
	private static var _nativeCorrection:Map<String, Int> = new Map<String, Int>();
}
