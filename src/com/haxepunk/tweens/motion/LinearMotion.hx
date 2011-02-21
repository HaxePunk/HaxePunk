package net.flashpunk.tweens.motion 
{
	import flash.geom.Point;
	
	/**
	 * Determines motion along a line, from one point to another.
	 */
	public class LinearMotion extends Motion
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function LinearMotion(complete:Function = null, type:uint = 0)
		{
			super(0,complete, type, null);
		}
		
		/**
		 * Starts moving along a line.
		 * @param	fromX		X start.
		 * @param	fromY		Y start.
		 * @param	toX			X finish.
		 * @param	toY			Y finish.
		 * @param	duration	Duration of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotion(fromX:Number, fromY:Number, toX:Number, toY:Number, duration:Number, ease:Function = null):void
		{
			_distance = -1;
			x = _fromX = fromX;
			y = _fromY = fromY;
			_moveX = toX - fromX;
			_moveY = toY - fromY;
			_target = duration;
			_ease = ease;
			start();
		}
		
		/**
		 * Starts moving along a line at the speed.
		 * @param	fromX		X start.
		 * @param	fromY		Y start.
		 * @param	toX			X finish.
		 * @param	toY			Y finish.
		 * @param	speed		Speed of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotionSpeed(fromX:Number, fromY:Number, toX:Number, toY:Number, speed:Number, ease:Function = null):void
		{
			_distance = -1;
			x = _fromX = fromX;
			y = _fromY = fromY;
			_moveX = toX - fromX;
			_moveY = toY - fromY;
			_target = distance / speed;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			x = _fromX + _moveX * _t;
			y = _fromY + _moveY * _t;
		}
		
		/**
		 * Length of the current line of movement.
		 */
		public function get distance():Number
		{
			if (_distance >= 0) return _distance;
			return (_distance = Math.sqrt(_moveX * _moveX + _moveY * _moveY));
		}
		
		// Line information.
		/** @private */ private var _fromX:Number = 0;
		/** @private */ private var _fromY:Number = 0;
		/** @private */ private var _moveX:Number = 0;
		/** @private */ private var _moveY:Number = 0;
		/** @private */ private var _distance:Number = - 1;
	}
}