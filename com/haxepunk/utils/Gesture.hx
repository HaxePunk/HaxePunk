package com.haxepunk.utils;

import com.haxepunk.HXP;

/**
 * Gesture input. Used to support complex touch input such as swipes,
 * pinch/zoom, and long or quick taps.
 * @since	2.5.3
 */
class GestureType
{
	public var x:Float = 0;
	public var y:Float = 0;
	public var x2:Float = 0;
	public var y2:Float = 0;
	public var magnitude:Float = 0;
	public var time:Float = 0;

	public var active:Bool = false;
	public var pressed:Bool = false;
	public var released:Bool = false;

	public function new()
	{
		reset();
	}

	function reset()
	{
		x = y = x2 = y2 = time = 0;
		active = pressed = released = false;
	}

	public function start(x:Float=0, y:Float=0)
	{
		active = pressed = true;
		this.x = x;
		this.y = y;
		x2 = y2 = magnitude = 0;
		this.time = 0;
	}

	public var distance(get, never):Float;
	function get_distance()
	{
		return HXP.distance(x, y, x2, y2);
	}

	public var velocity(get, never):Float;
	function get_velocity()
	{
		return time == 0 ? 0 : distance / time;
	}

	public var angle(get, never):Float;
	function get_angle()
	{
		// TODO
		return 0;
	}

	public function release()
	{
		released = true;
	}

	public function update()
	{
		if (pressed)
		{
			pressed = false;
		}
		else if (released)
		{
			reset();
		}
		else if (active)
		{
			time += HXP.elapsed;
		}
	}
}

@:enum
abstract GestureMode(Int)
{
	var READY = 0;
	var SINGLE_TOUCH = 1;
	var SINGLE_MOVE = 2;
	var MULTI_TOUCH = 3;
	var MULTI_MOVE = 4;
	var FINISHED = 5;
}

@:enum
abstract Gesture(Int) from Int to Int
{
	// a quick one-finger tap
	var TAP = 1;
	// two quick one-finger taps
	var DOUBLE_TAP = 2;
	// one-finger tap and hold
	var LONG_PRESS = 3;
	// tap and move; may be concurrent with LONG_PRESS if a LONG_PRESS was
	// initiated first
	var MOVE = 4;
	// two-finger touch and move in opposite directions
	// zoom out if magnitude < 1, zoom in if > 1
	var PINCH = 5;
	// two-finger quick tap
	var TWO_FINGER_TAP = 6;
	// not yet implemented
	//public static inline var ROTATE = 7;

	// how long a touch must be held to become a LONG_PRESS
	public static var longPressTime:Float = 0.5;
	// if two taps register before this much time passes,
	// the second one will be a DOUBLE_TAP
	public static var doubleTapTime:Float = 0.5;
	// if the distance between start and end position of a gesture is
	// less than this value, it will be considered a TAP/LONG_PRESS,
	// not a MOVE
	public static var deadZone:Float = 5;

	public static var enabled:Bool = false;

	static var mode:GestureMode;
	public static var gestures:Map<Int, GestureType> = new Map();

	/**
	 * Start responding to touch input.
	 */
	public static function enable()
	{
		enabled = true;
		mode = READY;
	}

	/**
	 * Stop responding to touch input.
	 */
	public static function disable()
	{
		enabled = false;
	}

	static inline function getTouch(touches:Map<Int, Touch>, touchOrder:Array<Int>, n:Int):Touch
	{
		if (n >= touchOrder.length) return null;
		return touches[touchOrder[n]];
	}

	/**
	 * Returns true if a gesture is active.
	 */
	public static function check(gestureType:Int)
	{
		if (!gestures.exists(gestureType)) return false;
		return (gestures[gestureType].active);
	}

	/**
	 * Returns true if a gesture was started this frame.
	 */
	public static function pressed(gestureType:Int)
	{
		if (!gestures.exists(gestureType)) return false;
		return (gestures[gestureType].pressed);
	}

	/**
	 * Returns true if a gesture was released this frame.
	 */
	public static function released(gestureType:Int)
	{
		if (!gestures.exists(gestureType)) return false;
		return (gestures[gestureType].released);
	}

	/**
	 * Get an object describing an active gesture.
	 */
	public static function get(gestureType:Int):GestureType
	{
		if (!check(gestureType)) return null;
		return (gestures[gestureType]);
	}

	/**
	 * Start a gesture.
	 */
	static function start(gestureType:Int, x:Float=0, y:Float=0)
	{
		if (!gestures.exists(gestureType))
		{
			gestures[gestureType] = new GestureType();
		}
		if (!gestures[gestureType].active)
		{
			gestures[gestureType].start(x, y);
		}
	}

	/**
	 * Finish a gesture.
	 */
	static function finish(gestureType)
	{
		if (!gestures.exists(gestureType))
		{
			gestures[gestureType] = new GestureType();
		}
		gestures[gestureType].release();
	}

	static function finishAll()
	{
		for (gesture in gestures)
		{
			if (gesture.active)
			{
				gesture.release();
			}
		}
	}

	/**
	 * Check for gestures.
	 */
	public static function update()
	{
		for (gesture in gestures)
		{
			gesture.update();
		}

		var touches = Input.touches;
		var touchOrder = Input.touchOrder;
		var touchCount:Int = 0;
		for (touch in touchOrder)
		{
			if (touches.exists(touch))
			{
				if (touches[touch].pressed || !touches[touch].released) touchCount += 1;
			}
			else
			{
				touchOrder.remove(touch);
			}
		}

		if (_lastTap > 0) _lastTap = Math.max(0, _lastTap - HXP.elapsed / doubleTapTime);

		switch (mode)
		{
			case READY:
			{
				if (touchCount > 0)
				{
					// start tracking gesture
					mode = touchCount == 1 ? SINGLE_TOUCH : MULTI_TOUCH;
				}
			}
			case SINGLE_TOUCH:
			{
				if (touchCount == 0)
				{
					// was touching with one finger, now released
					// initiate a tap or long press
					mode = READY;
					var touch:Touch = getTouch(touches, touchOrder, 0);
					var t:Int = (touch.time < longPressTime) ? TAP : LONG_PRESS;
					
					if (t == TAP && _lastTap > 0) t = DOUBLE_TAP;
					
					if (!check(t))
					{
						start(t, touch.x, touch.y);
						if (t == TAP) _lastTap = 1;
					}
				}
				else if (touchCount == 1)
				{
					var touch:Touch = getTouch(touches, touchOrder, 0);
					var dist = HXP.distance(touch.startX, touch.startY, touch.x, touch.y);
					if (dist > deadZone)
					{
						mode = SINGLE_MOVE;
					}
					else if (touch.time >= longPressTime && !check(LONG_PRESS))
					{
						start(LONG_PRESS, touch.x, touch.y);
					}
				}
				else if (touchCount > 1)
				{
					mode = MULTI_TOUCH;
				}
			}
			case SINGLE_MOVE:
			{
				if (touchCount == 0)
				{
					mode = READY;
				}
				else
				{
					var touch:Touch = getTouch(touches, touchOrder, 0);
					var dist = HXP.distance(touch.startX, touch.startY, touch.x, touch.y);
					if (!check(MOVE))
					{
						start(MOVE, touch.startX, touch.startY);
					}
					var g = get(MOVE);
					g.x2 = touch.x;
					g.y2 = touch.y;
					g.magnitude = dist;
				}
				if (touchCount > 1)
				{
					var touch:Touch = getTouch(touches, touchOrder, 1);
					start(TWO_FINGER_TAP, touch.x, touch.y);
				}
				else if (check(TWO_FINGER_TAP))
				{
					finish(TWO_FINGER_TAP);
				}
			}
			case MULTI_TOUCH:
			{
				if (touchCount < 2)
				{
					mode = (touchCount == 0 ? READY : FINISHED);
					if (!check(PINCH))
					{
						var t1:Touch = getTouch(touches, touchOrder, 0);
						var t2:Touch = getTouch(touches, touchOrder, 1);
						if (t2 != null)
						{
							var mx = (t1.startX - t2.startX) / 2;
							var my = (t1.startY - t2.startY) / 2;
							start(TWO_FINGER_TAP, mx, my);
						}
					}
					finishAll();
				}
				else
				{
					var t1:Touch = getTouch(touches, touchOrder, 0);
					var t2:Touch = getTouch(touches, touchOrder, 1);
					if (t1 != null && t2 != null)
					{
						var d1 = HXP.distance(t1.startX, t1.startY, t1.x, t1.y);
						var d2 = HXP.distance(t2.startX, t2.startY, t2.x, t2.y);
						if (d1 > deadZone && d2 > deadZone)
						{
							if (!check(PINCH))
							{
								var mx = (t1.startX - t2.startX) / 2;
								var my = (t1.startY - t2.startY) / 2;
								start(PINCH, mx, my);
							}
							var inner = HXP.distance(t1.startX, t1.startY, t2.startX, t2.startY);
							var outer = HXP.distance(t1.x, t1.y, t2.x, t2.y);
							get(PINCH).magnitude = inner / outer;
						}
					}
				}
			}
			default:
			{
				if (touchCount == 0)
				{
					mode = READY;
				}
			}
		}

		if (touchCount == 0) finishAll();
	}

	static var _lastTap:Float = 0;
}
