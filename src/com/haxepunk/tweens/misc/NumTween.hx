package net.flashpunk.tweens.misc 
{
	import net.flashpunk.Tween;
	
	/**
	 * Tweens a numeric value.
	 */
	public class NumTween extends Tween
	{
		/**
		 * The current value.
		 */
		public var value:Number = 0;
		
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function NumTween(complete:Function = null, type:uint = 0) 
		{
			super(0, type, complete);
		}
		
		/**
		 * Tweens the value from one value to another.
		 * @param	fromValue		Start value.
		 * @param	toValue			End value.
		 * @param	duration		Duration of the tween.
		 * @param	ease			Optional easer function.
		 */
		public function tween(fromValue:Number, toValue:Number, duration:Number, ease:Function = null):void
		{
			_start = value = fromValue;
			_range = toValue - value;
			_target = duration;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			value = _start + _range * _t;
		}
		
		// Tween information.
		/** @private */ private var _start:Number;
		/** @private */ private var _range:Number;
	}
}