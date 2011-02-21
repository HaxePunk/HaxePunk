package net.flashpunk.tweens.misc
{
	import net.flashpunk.Tween;
	
	/**
	 * A simple alarm, useful for timed events, etc.
	 */
	public class Alarm extends Tween
	{
		/**
		 * Constructor.
		 * @param	duration	Duration of the alarm.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function Alarm(duration:Number, complete:Function = null, type:uint = 0) 
		{
			super(duration, type, complete, null);
		}
		
		/**
		 * Sets the alarm.
		 * @param	duration	Duration of the alarm.
		 */
		public function reset(duration:Number):void
		{
			_target = duration;
			start();
		}
		
		/**
		 * How much time has passed since reset.
		 */
		public function get elapsed():Number { return _time; }
		
		/**
		 * Current alarm duration.
		 */
		public function get duration():Number { return _target; }
		
		/**
		 * Time remaining on the alarm.
		 */
		public function get remaining():Number { return _target - _time; }
	}
}