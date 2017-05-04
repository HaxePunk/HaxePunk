package haxepunk.tweens.misc;

import haxepunk.Tween;

/**
 * Tweens multiple numeric public properties of an Object simultaneously.
 */
class MultiVarTween extends Tween
{
	/**
	 * Constructor.
	 * @param	complete		Optional completion callback.
	 * @param	type			Tween type.
	 */
	public function new(?complete:Dynamic -> Void, ?type:TweenType)
	{
		_vars = new Array<String>();
		_start = new Array<Float>();
		_range = new Array<Float>();

		super(0, type, complete);
	}

	/**
	 * Tweens multiple numeric public properties.
	 * @param	object		The object containing the properties.
	 * @param	properties	An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 * @param	ease		Optional easer function.
	 */
	public function tween(object:Dynamic, properties:Dynamic, duration:Float, ease:Float -> Float = null)
	{
		_object = object;
		HXP.clear(_vars);
		HXP.clear(_start);
		HXP.clear(_range);
		_target = duration;
		_ease = ease;
		var p:String;

		var fields:Array<String> = null;
		if (Reflect.isObject(properties))
		{
			fields = Reflect.fields(properties);
		}
		else
		{
			throw "Unsupported MultiVar properties container - use Object containing key/value pairs.";
		}

		for (p in fields)
		{
			var a:Float = Reflect.getProperty(object, p);

			if (Math.isNaN(a))
			{
				throw 'The property $p is not numeric.';
			}
			_vars.push(p);
			_start.push(a);
			_range.push(Reflect.field(properties, p) - a);
		}
		start();
	}

	/** @private Updates the Tween. */
	@:dox(hide)
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var i:Int = _vars.length;

		while (i-- > 0)
		{
			Reflect.setProperty(_object, _vars[i], _start[i] + _range[i] * _t);
		}
	}

	// Tween information.
	var _object:Dynamic;
	var _vars:Array<String>;
	var _start:Array<Float>;
	var _range:Array<Float>;
}
