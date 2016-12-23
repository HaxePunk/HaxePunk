﻿package haxepunk.tweens.misc;

import haxepunk.Tween;
import haxepunk.utils.Ease;

/**
 * Tweens a numeric value.
 */
class NumTween extends Tween
{
	/**
	 * The current value.
	 */
	public var value:Float;
	
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:Dynamic -> Void, ?type:TweenType) 
	{
		value = 0;
		super(0, type, complete);
	}
	
	/**
	 * Tweens the value from one value to another.
	 * @param	fromValue		Start value.
	 * @param	toValue			End value.
	 * @param	duration		Duration of the tween.
	 * @param	ease			Optional easer function.
	 */
	public function tween(fromValue:Float, toValue:Float, duration:Float, ?ease:Float -> Float)
	{
		_start = value = fromValue;
		_range = toValue - value;
		_target = duration;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	@:dox(hide)
	override public function update() 
	{
		super.update();
		value = _start + _range * _t;
	}
	
	// Tween information.
	private var _start:Float;
	private var _range:Float;
}
