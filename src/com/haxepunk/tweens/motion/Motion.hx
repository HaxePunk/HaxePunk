package net.flashpunk.tweens.motion 
{
	import net.flashpunk.Tween;
	
	/**
	 * Base class for motion Tweens.
	 */
	public class Motion extends Tween
	{
		/**
		 * Current x position of the Tween.
		 */
		public var x:Number = 0;
		
		/**
		 * Current y position of the Tween.
		 */
		public var y:Number = 0;
		
		/**
		 * Constructor.
		 * @param	duration	Duration of the Tween.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 * @param	ease		Optional easer function.
		 */
		public function Motion(duration:Number, complete:Function = null, type:uint = 0, ease:Function = null) 
		{
			super(duration, type, complete, ease);
		}
	}
}