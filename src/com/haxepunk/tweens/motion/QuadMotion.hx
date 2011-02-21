package net.flashpunk.tweens.motion 
{
	import flash.geom.Point;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Ease;
	
	/**
	 * Determines motion along a quadratic curve.
	 */
	public class QuadMotion extends Motion
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function QuadMotion(complete:Function = null, type:uint = 0)
		{
			super(0, complete, type, null);
		}
		
		/**
		 * Starts moving along the curve.
		 * @param	fromX		X start.
		 * @param	fromY		Y start.
		 * @param	controlX	X control, used to determine the curve.
		 * @param	controlY	Y control, used to determine the curve.
		 * @param	toX			X finish.
		 * @param	toY			Y finish.
		 * @param	duration	Duration of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotion(fromX:Number, fromY:Number, controlX:Number, controlY:Number, toX:Number, toY:Number, duration:Number, ease:Function = null):void
		{
			_distance = -1;
			x = _fromX = fromX;
			y = _fromY = fromY;
			_controlX = controlX;
			_controlY = controlY;
			_toX = toX;
			_toY = toY;
			_target = duration;
			_ease = ease;
			start();
		}
		
		/**
		 * Starts moving along the curve at the speed.
		 * @param	fromX		X start.
		 * @param	fromY		Y start.
		 * @param	controlX	X control, used to determine the curve.
		 * @param	controlY	Y control, used to determine the curve.
		 * @param	toX			X finish.
		 * @param	toY			Y finish.
		 * @param	speed		Speed of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotionSpeed(fromX:Number, fromY:Number, controlX:Number, controlY:Number, toX:Number, toY:Number, speed:Number, ease:Function = null):void
		{
			_distance = -1;
			x = _fromX = fromX;
			y = _fromY = fromY;
			_controlX = controlX;
			_controlY = controlY;
			_toX = toX;
			_toY = toY;
			_target = distance / speed;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			x = _fromX * (1 - _t) * (1 - _t) + _controlX * 2 * (1 - _t) * _t + _toX * _t * _t;
			y = _fromY * (1 - _t) * (1 - _t) + _controlY * 2 * (1 - _t) * _t + _toY * _t * _t;
		}
		
		/**
		 * The distance of the entire curve.
		 */
		public function get distance():Number
		{
			if (_distance >= 0) return _distance;
			var a:Point = FP.point,
				b:Point = FP.point2;
			a.x = x - 2 * _controlX + _toX;
			a.y = y - 2 * _controlY + _toY;
			b.x = 2 * _controlX - 2 * x;
			b.y = 2 * _controlY - 2 * y;
			var A:Number = 4 * (a.x * a.x + a.y * a.y),
				B:Number = 4 * (a.x * b.x + a.y * b.y),
				C:Number = b.x * b.x + b.y * b.y,
				ABC:Number = 2 * Math.sqrt(A + B + C),
				A2:Number = Math.sqrt(A),
				A32:Number = 2 * A * A2,
				C2:Number = 2 * Math.sqrt(C),
				BA:Number = B / A2;
			return (A32 * ABC + A2 * B * (ABC - C2) + (4 * C * A - B * B) * Math.log((2 * A2 + BA + ABC) / (BA + C2))) / (4 * A32);
		}
		
		// Curve information.
		/** @private */ private var _distance:Number = -1;
		/** @private */ private var _fromX:Number = 0;
		/** @private */ private var _fromY:Number = 0;
		/** @private */ private var _toX:Number = 0;
		/** @private */ private var _toY:Number = 0;
		/** @private */ private var _controlX:Number = 0;
		/** @private */ private var _controlY:Number = 0;
	}
}