package haxepunk.backend.flash;

import flash.events.TouchEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import haxepunk.input.Touch;

@:access(haxepunk.input.Touch)
class TouchInput
{
	public static function init(app:FlashApiApp)
	{
		var stage = app.stage;
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
	}

	static function onTouchBegin(e:TouchEvent)
	{
		var touchPoint = new Touch(e.stageX / HXP.screen.fullScaleX, e.stageY / HXP.screen.fullScaleY, e.touchPointID);
		Touch._touches.set(e.touchPointID, touchPoint);
		Touch._touchOrder.push(e.touchPointID);
	}

	static function onTouchMove(e:TouchEvent)
	{
		// maybe we missed the begin event sometimes?
		if (Touch._touches.exists(e.touchPointID))
		{
			var point = Touch._touches.get(e.touchPointID);
			point.x = e.stageX / HXP.screen.fullScaleX;
			point.y = e.stageY / HXP.screen.fullScaleY;
		}
	}

	static function onTouchEnd(e:TouchEvent)
	{
		if (Touch._touches.exists(e.touchPointID))
		{
			Touch._touches.get(e.touchPointID).released = true;
		}
	}
}
