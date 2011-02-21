package net.flashpunk.tweens.misc
{
	import net.flashpunk.Tween;
	
	/**
	 * Tweens a numeric public property of an Object.
	 */
	public class VarTween extends Tween
	{
		/**
		 * Constructor.
		 * @param	complete	Optional completion callback.
		 * @param	type		Tween type.
		 */
		public function VarTween(complete:Function = null, type:uint = 0) 
		{
			super(0, type, complete);
		}
		
		/**
		 * Tweens a numeric public property.
		 * @param	object		The object containing the property.
		 * @param	property	The name of the property (eg. "x").
		 * @param	to			Value to tween to.
		 * @param	duration	Duration of the tween.
		 * @param	ease		Optional easer function.
		 */
		public function tween(object:Object, property:String, to:Number, duration:Number, ease:Function = null):void
		{
			_object = object;
			_property = property;
			_ease = ease;
			if (!object.hasOwnProperty(property)) throw new Error("The Object does not have the property\"" + property + "\", or it is not accessible.");
			var a:* = _object[property] as Number;
			if (a == null) throw new Error("The property \"" + property + "\" is not numeric.");
			_start = _object[property];
			_range = to - _start;
			_target = duration;
			start();
		}
		
		/** @private Updates the Tween. */
		override public function update():void 
		{
			super.update();
			_object[_property] = _start + _range * _t;
		}
		
		// Tween information.
		/** @private */ private var _object:Object;
		/** @private */ private var _property:String;
		/** @private */ private var _start:Number;
		/** @private */ private var _range:Number;
	}
}