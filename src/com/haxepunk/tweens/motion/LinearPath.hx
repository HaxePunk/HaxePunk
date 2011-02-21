package net.flashpunk.tweens.motion 
{
	import flash.geom.Point;
	import net.flashpunk.FP;
	
	/**
	 * Determines linear motion along a set of points.
	 */
	public class LinearPath extends Motion
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function LinearPath(complete:Function = null, type:uint = 0) 
		{
			super(0, complete, type, null);
			_pointD[0] = _pointT[0] = 0;
		}
		
		/**
		 * Starts moving along the path.
		 * @param	duration		Duration of the movement.
		 * @param	ease			Optional easer function.
		 */
		public function setMotion(duration:Number, ease:Function = null):void
		{
			updatePath();
			_target = duration;
			_speed = _distance / duration;
			_ease = ease;
			start();
		}
		
		/**
		 * Starts moving along the path at the speed.
		 * @param	speed		Speed of the movement.
		 * @param	ease		Optional easer function.
		 */
		public function setMotionSpeed(speed:Number, ease:Function = null):void
		{
			updatePath();
			_target = _distance / speed;
			_speed = speed;
			_ease = ease;
			start();
		}
		
		/**
		 * Adds the point to the path.
		 * @param	x		X position.
		 * @param	y		Y position.
		 */
		public function addPoint(x:Number = 0, y:Number = 0):void
		{
			if (_last)
			{
				_distance += Math.sqrt((x - _last.x) * (x - _last.x) + (y - _last.y) * (y - _last.y));
				_pointD[_points.length] = _distance;
			}
			_points[_points.length] = _last = new Point(x, y);
		}
		
		/**
		 * Gets a point on the path.
		 * @param	index		Index of the point.
		 * @return	The Point object.
		 */
		public function getPoint(index:uint = 0):Point
		{
			if (!_points.length) throw new Error("No points have been added to the path yet.");
			return _points[index % _points.length];
		}
		
		/** @private Starts the Tween. */
		override public function start():void 
		{
			_index = 0;
			super.start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			if (_index < _points.length - 1)
			{
				while (_t > _pointT[_index + 1]) _index ++;
			}
			var td:Number = _pointT[_index],
				tt:Number = _pointT[_index + 1] - td;
			td = (_t - td) / tt;
			_prev = _points[_index];
			_next = _points[_index + 1];
			x = _prev.x + (_next.x - _prev.x) * td;
			y = _prev.y + (_next.y - _prev.y) * td;
		}
		
		/** @private Updates the path, preparing it for motion. */
		private function updatePath():void
		{
			if (_points.length < 2)	throw new Error("A LinearPath must have at least 2 points to operate.");
			if (_pointD.length == _pointT.length) return;
			// evaluate t for each point
			var i:int = 0;
			while (i < _points.length) _pointT[i] = _pointD[i ++] / _distance;
		}
		
		/**
		 * The full length of the path.
		 */
		public function get distance():Number { return _distance; }
		
		/**
		 * How many points are on the path.
		 */
		public function get pointCount():Number { return _points.length; }
		
		// Path information.
		/** @private */ private var _points:Vector.<Point> = new Vector.<Point>;
		/** @private */ private var _pointD:Vector.<Number> = new Vector.<Number>;
		/** @private */ private var _pointT:Vector.<Number> = new Vector.<Number>;
		/** @private */ private var _distance:Number = 0;
		/** @private */ private var _speed:Number = 0;
		/** @private */ private var _index:uint = 0;
		
		// Line information.
		/** @private */ private var _last:Point;
		/** @private */ private var _prev:Point;
		/** @private */ private var _next:Point;
	}
}