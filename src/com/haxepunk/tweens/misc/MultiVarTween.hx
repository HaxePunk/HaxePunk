package net.flashpunk.tweens.misc
{
	import net.flashpunk.Tween;

	/**
	 * Tweens multiple numeric public properties of an Object simultaneously.
	 */
	public class MultiVarTween extends Tween
	{
		/**
		 * Constructor.
		 * @param	complete		Optional completion callback.
		 * @param	type			Tween type.
		 */
		public function MultiVarTween(complete:Function = null, type:uint = 0)
		{
			super(0, type, complete);
		}
		
		/**
		 * Tweens multiple numeric public properties.
		 * @param	object		The object containing the properties.
		 * @param	values		An object containing key/value pairs of properties and target values.
		 * @param	duration	Duration of the tween.
		 * @param	ease		Optional easer function.
		 */
		public function tween(object:Object, values:Object, duration:Number, ease:Function = null):void
		{
			_object = object;
			_vars.length = 0;
			_start.length = 0;
			_range.length = 0;
			_target = duration;
			_ease = ease;
			for (var p:String in values)
			{
				if (!object.hasOwnProperty(p)) throw new Error("The Object does not have the property\"" + p + "\", or it is not accessible.");
				var a:* = _object[p] as Number;
				if (a == null) throw new Error("The property \"" + p + "\" is not numeric.");
				_vars.push(p);
				_start.push(a);
				_range.push(values[p] - a);
			}
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void
		{
			super.update();
			var i:int = _vars.length;
			while (i --) _object[_vars[i]] = _start[i] + _range[i] * _t;
		}

		// Tween information.
		/** @private */ private var _object:Object;
		/** @private */ private var _vars:Vector.<String> = new Vector.<String>;
		/** @private */ private var _start:Vector.<Number> = new Vector.<Number>;
		/** @private */ private var _range:Vector.<Number> = new Vector.<Number>;
	}
}