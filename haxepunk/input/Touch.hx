package haxepunk.input;

import flash.events.TouchEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import haxepunk.HXP;
import haxepunk.math.Vector2;

class Touch
{
	public static function init()
	{
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		HXP.engine.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		HXP.engine.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		HXP.engine.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
	}

	public static function update()
	{
		for (touchId in _touchOrder) _touches[touchId].updateTouch();

		if (Gesture.enabled) Gesture.update();

		var i:Int = 0;
		while (i < _touchOrder.length)
		{
			var touchId = _touchOrder[i],
				touch = _touches[touchId];
			if (touch.released && !touch.pressed)
			{
				_touches.remove(touchId);
				_touchOrder.remove(touchId);
			}
			else ++i;
		}
	}

	public static function postUpdate() {}

	// TODO
	public static function checkInput(input:InputType):Bool return false;
	public static function pressedInput(input:InputType):Bool return false;
	public static function releasedInput(input:InputType):Bool return false;

	public static function touchPoints(touchCallback:Touch->Void)
	{
		for (touchId in _touchOrder)
		{
			touchCallback(_touches[touchId]);
		}
	}

	public static var touches(get, never):Map<Int, Touch>;
	static inline function get_touches():Map<Int, Touch> return _touches;

	public static var touchOrder(get, never):Array<Int>;
	static inline function get_touchOrder():Array<Int> return _touchOrder;

	static var _touches:Map<Int, Touch> = new Map<Int, Touch>();
	static var _touchOrder:Array<Int> = new Array();

	static function onTouchBegin(e:TouchEvent)
	{
		var touchPoint = new Touch(e.stageX / HXP.screen.fullScaleX, e.stageY / HXP.screen.fullScaleY, e.touchPointID);
		_touches.set(e.touchPointID, touchPoint);
		_touchOrder.push(e.touchPointID);
	}

	static function onTouchMove(e:TouchEvent)
	{
		// maybe we missed the begin event sometimes?
		if (_touches.exists(e.touchPointID))
		{
			var point = _touches.get(e.touchPointID);
			point.x = e.stageX / HXP.screen.fullScaleX;
			point.y = e.stageY / HXP.screen.fullScaleY;
		}
	}

	static function onTouchEnd(e:TouchEvent)
	{
		if (_touches.exists(e.touchPointID))
		{
			_touches.get(e.touchPointID).released = true;
		}
	}

	/**
	 * Touch id used for multiple touches
	 */
	public var id(default, null):Int;
	/**
	 * X-Axis coord in window
	 */
	public var x:Float;
	/**
	 * Y-Axis coord in window
	 */
	public var y:Float;
	/**
	 * Starting X position of touch
	 */
	public var startX:Float;
	/**
	 * Starting Y position of touch
	 */
	public var startY:Float;
	/**
	 * The time this touch has been held
	 */
	public var time(default, null):Float;

	/**
	 * Creates a new touch object
	 * @param  x  x-axis coord in window
	 * @param  y  y-axis coord in window
	 * @param  id touch id
	 */
	public function new(x:Float, y:Float, id:Int)
	{
		this.startX = this.x = x;
		this.startY = this.y = y;
		this.id = id;
		this.time = 0;
	}

	public inline function cameraOffset(camera:Camera):Vector2
	{
		return new Vector2(x + camera.x, y + camera.y);
	}

	/**
	 * If the touch was pressed this frame.
	 */
	public var pressed(get, never):Bool;
	inline function get_pressed():Bool return time == 0;

	/**
	 * Not implemented yet. Always return false.
	 */
	public var released:Bool = false;

	/**
	 * Updates the touch state.
	 */
	@:dox(hide)
	function updateTouch()
	{
		time += HXP.elapsed;
	}
}
