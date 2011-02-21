package net.flashpunk.tweens.misc 
{
	import net.flashpunk.FP;
	import net.flashpunk.Tween;
	
	/**
	 * Tweens from one angle to another.
	 */
	public class AngleTween extends Tween
	{
		/**
		 * The current value.
		 */
		public var angle:Number = 0;
		
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function AngleTween(complete:Function = null, type:uint = 0) 
		{
			super(0, type, complete);
		}
		
		/**
		 * Tweens the value from one angle to another.
		 * @param	fromAngle		Start angle.
		 * @param	toAngle			End angle.
		 * @param	duration		Duration of the tween.
		 * @param	ease			Optional easer function.
		 */
		public function tween(fromAngle:Number, toAngle:Number, duration:Number, ease:Function = null):void
		{
			_start = angle = fromAngle;
			var d:Number = toAngle - angle,
				a:Number = Math.abs(d);
			if (a > 181) _range = (360 - a) * (d > 0 ? -1 : 1);
			else if (a < 179) _range = d;
			else _range = FP.choose(180, -180);
			_target = duration;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			angle = (_start + _range * _t) % 360;
			if (angle < 0) angle += 360;
		}
		
		// Tween information.
		/** @private */ private var _start:Number;
		/** @private */ private var _range:Number;
	}
}