package net.flashpunk.tweens.sound 
{
	import net.flashpunk.FP;
	import net.flashpunk.Tween;
	
	/**
	 * Global volume fader.
	 */
	public class Fader extends Tween
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function Fader(complete:Function = null, type:uint = 0) 
		{
			super(0, type, complete);
		}
		
		/**
		 * Fades FP.volume to the target volume.
		 * @param	volume		The volume to fade to.
		 * @param	duration	Duration of the fade.
		 * @param	ease		Optional easer function.
		 */
		public function fadeTo(volume:Number, duration:Number, ease:Function = null):void
		{
			if (volume < 0) volume = 0;
			_start = FP.volume;
			_range = volume - _start;
			_target = duration;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			FP.volume = _start + _range * _t;
		}
		
		// Fader information.
		/** @private */ private var _start:Number;
		/** @private */ private var _range:Number;
	}
}