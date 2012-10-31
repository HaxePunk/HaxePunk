package com.haxepunk.tweens.misc;

import com.haxepunk.Tween;
import com.haxepunk.utils.Ease;

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
	public function new(?complete:CompleteCallback, ?type:TweenType)
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
	public function tween(object:Dynamic, properties:Dynamic, duration:Float, ease:EaseFunction = null)
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
				throw "The property \"" + p + "\" is not numeric.";
			}
			_vars.push(p);
			_start.push(a);
			_range.push(Reflect.field(properties, p) - a);
		}
		start();
	}

	/** @private Updates the Tween. */
	override function _update()
	{
		super._update();
		var i:Int = _vars.length;
		var setter:Dynamic->String->Dynamic->Void;
#if (cpp || neko)
		setter = Reflect.setField;
#else
		setter = Reflect.setProperty;
#end
		while (i-- > 0)
		{
			setter(_object, _vars[i], _start[i] + _range[i] * _t);
		}
	}

	// Tween information.
	private var _object:Dynamic;
	private var _vars:Array<String>;
	private var _start:Array<Float>;
	private var _range:Array<Float>;
}