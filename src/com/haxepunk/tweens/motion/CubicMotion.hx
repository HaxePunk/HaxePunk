package net.flashpunk.tweens.motion 
{
	import flash.geom.Point;
	import net.flashpunk.utils.Ease;
	
	/**
	 * Determines motion along a cubic curve.
	 */
	public class CubicMotion extends Motion
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function CubicMotion(complete:Function = null, type:uint = 0)
		{
			super(0, complete, type, null);
		}
		
		/**
		 * Starts moving along the curve.
		 * @param	fromX		X start.
		 * @param	fromY		Y start.
		 * @param	aX			First control x.
		 * @param	aY			First control y.
		 * @param	bX			Second control x.
		 * @param	bY			Second control y.
		 * @param	toX			X finish.
		 * @param	toY			Y finish.
		 * @param	duration	Duration of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotion(fromX:Number, fromY:Number, aX:Number, aY:Number, bX:Number, bY:Number, toX:Number, toY:Number, duration:Number, ease:Function = null):void
		{
			x = _fromX = fromX;
			y = _fromY = fromY;
			_aX = aX;
			_aY = aY;
			_bX = bX;
			_bY = bY;
			_toX = toX;
			_toY = toY;
			_target = duration;
			_ease = ease;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			x = _t * _t * _t * (_toX + 3 * (_aX - _bX) - _fromX) + 3 * _t * _t * (_fromX - 2 * _aX + _bX) + 3 * _t * (_aX - _fromX) + _fromX;
			y = _t * _t * _t * (_toY + 3 * (_aY - _bY) - _fromY) + 3 * _t * _t * (_fromY - 2 * _aY + _bY) + 3 * _t * (_aY - _fromY) + _fromY;
		}
		
		// Curve information.
		/** @private */ private var _fromX:Number = 0;
		/** @private */ private var _fromY:Number = 0;
		/** @private */ private var _toX:Number = 0;
		/** @private */ private var _toY:Number = 0;
		/** @private */ private var _aX:Number = 0;
		/** @private */ private var _aY:Number = 0;
		/** @private */ private var _bX:Number = 0;
		/** @private */ private var _bY:Number = 0;
		/** @private */ private var _ttt:Number;
		/** @private */ private var _tt:Number;
	}
}