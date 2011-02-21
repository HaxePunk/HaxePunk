package net.flashpunk.tweens.motion 
{
	import flash.geom.Point;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Ease;
	
	/**
	 * Determines a circular motion.
	 */
	public class CircularMotion extends Motion
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function CircularMotion(complete:Function = null, type:uint = 0)
		{
			super(0, complete, type, null);
		}
		
		/**
		 * Starts moving along a circle.
		 * @param	centerX		X position of the circle's center.
		 * @param	centerY		Y position of the circle's center.
		 * @param	radius		Radius of the circle.
		 * @param	angle		Starting position on the circle.
		 * @param	clockwise	If the motion is clockwise.
		 * @param	duration	Duration of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotion(centerX:Number, centerY:Number, radius:Number, angle:Number, clockwise:Boolean, duration:Number, ease:Function = null):void
		{
			_centerX = centerX;
			_centerY = centerY;
			_radius = radius;
			_angle = _angleStart = angle * FP.RAD;
			_angleFinish = _CIRC * (clockwise ? 1 : -1);
			_target = duration;
			_ease = ease;
			start();
		}
		
		/**
		 * Starts moving along a circle at the speed.
		 * @param	centerX		X position of the circle's center.
		 * @param	centerY		Y position of the circle's center.
		 * @param	radius		Radius of the circle.
		 * @param	angle		Starting position on the circle.
		 * @param	clockwise	If the motion is clockwise.
		 * @param	speed		Speed of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotionSpeed(centerX:Number, centerY:Number, radius:Number, angle:Number, clockwise:Boolean, speed:Number, ease:Function = null):void
		{
			_centerX = centerX;
			_centerY = centerY;
			_radius = radius;
			_angle = _angleStart = angle * FP.RAD;
			_angleFinish = _CIRC * (clockwise ? 1 : -1);
			_target = (_radius * _CIRC) / speed;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			_angle = _angleStart + _angleFinish * _t;
			x = _centerX + Math.cos(_angle) * _radius;
			y = _centerY + Math.sin(_angle) * _radius;
		}
		
		/**
		 * The current position on the circle.
		 */
		public function get angle():Number { return _angle; }
		
		/**
		 * The circumference of the current circle motion.
		 */
		public function get circumference():Number { return _radius * _CIRC; }
		
		// Circle information.
		/** @private */ private var _centerX:Number = 0;
		/** @private */ private var _centerY:Number = 0;
		/** @private */ private var _radius:Number = 0;
		/** @private */ private var _angle:Number = 0;
		/** @private */ private var _angleStart:Number = 0;
		/** @private */ private var _angleFinish:Number = 0;
		/** @private */ private static const _CIRC:Number = Math.PI * 2;
	}
}