package haxepunk._internal;

import haxepunk.input.Touch;

/**
 * Used to wire touch input back in to the touch-input handler.
 * **/
@:access(haxepunk.input.Touch)
class TouchInput
{
	public static function init()
	{
        kha.input.Surface.get.notify(onTouchBegin, onTouchEnd, onTouchMove);
	}

	static function onTouchBegin(id:Int, x:Int, y:Int)
	{
		var touchPoint = new Touch(x / HXP.screen.scaleX, y / HXP.screen.scaleY, id);
		Touch._touches.set(id, touchPoint);
		Touch._touchOrder.push(id);
	}

	static function onTouchMove(id:Int, x:Int, y:Int)
	{
        // TODO: is this really necessary?
		// maybe we missed the begin event sometimes?
		if (Touch._touches.exists(id))
		{
			var point = Touch._touches.get(id);
			point.x = x / HXP.screen.scaleX;
			point.y = y / HXP.screen.scaleY;
		}
	}

	static function onTouchEnd(id:Int, x:Int, y:Int)
	{
		if (Touch._touches.exists(id))
		{
			var point = Touch._touches.get(id);
			point.x = x / HXP.screen.scaleX;
			point.y = y / HXP.screen.scaleY;
            point.released = true;
		}
	}
}
