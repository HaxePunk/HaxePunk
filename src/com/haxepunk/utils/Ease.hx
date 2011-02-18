package com.haxepunk.utils;

/**
 * Static class with useful easer functions that can be used by Tweens.
 */
class Ease 
{
	/** Quadratic in. */
	public static function quadIn(t:Number):Number
	{
		return t * t;
	}
	
	/** Quadratic out. */
	public static function quadOut(t:Number):Number
	{
		return -t * (t - 2);
	}
	
	/** Quadratic in and out. */
	public static function quadInOut(t:Number):Number
	{
		return t <= .5 ? t * t * 2 : 1 - (--t) * t * 2;
	}
	
	/** Cubic in. */
	public static function cubeIn(t:Number):Number
	{
		return t * t * t;
	}
	
	/** Cubic out. */
	public static function cubeOut(t:Number):Number
	{
		return 1 + (--t) * t * t;
	}
	
	/** Cubic in and out. */
	public static function cubeInOut(t:Number):Number
	{
		return t <= .5 ? t * t * t * 4 : 1 + (--t) * t * t * 4;
	}
	
	/** Quart in. */
	public static function quartIn(t:Number):Number
	{
		return t * t * t * t;
	}
	
	/** Quart out. */
	public static function quartOut(t:Number):Number
	{
		return 1 - (t-=1) * t * t * t;
	}
	
	/** Quart in and out. */
	public static function quartInOut(t:Number):Number
	{
		return t <= .5 ? t * t * t * t * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
	}
	
	/** Quint in. */
	public static function quintIn(t:Number):Number
	{
		return t * t * t * t * t;
	}
	
	/** Quint out. */
	public static function quintOut(t:Number):Number
	{
		return (t = t - 1) * t * t * t * t + 1;
	}
	
	/** Quint in and out. */
	public static function quintInOut(t:Number):Number
	{
		return ((t *= 2) < 1) ? (t * t * t * t * t) / 2 : ((t -= 2) * t * t * t * t + 2) / 2;
	}
	
	/** Sine in. */
	public static function sineIn(t:Number):Number
	{
		return -Math.cos(PI2 * t) + 1;
	}
	
	/** Sine out. */
	public static function sineOut(t:Number):Number
	{
		return Math.sin(PI2 * t);
	}
	
	/** Sine in and out. */
	public static function sineInOut(t:Number):Number
	{
		return -Math.cos(PI * t) / 2 + .5;
	}
	
	/** Bounce in. */
	public static function bounceIn(t:Number):Number
	{
		t = 1 - t;
		if (t < B1) return 1 - 7.5625 * t * t;
		if (t < B2) return 1 - (7.5625 * (t - B3) * (t - B3) + .75);
		if (t < B4) return 1 - (7.5625 * (t - B5) * (t - B5) + .9375);
		return 1 - (7.5625 * (t - B6) * (t - B6) + .984375);
	}
	
	/** Bounce out. */
	public static function bounceOut(t:Number):Number
	{
		if (t < B1) return 7.5625 * t * t;
		if (t < B2) return 7.5625 * (t - B3) * (t - B3) + .75;
		if (t < B4) return 7.5625 * (t - B5) * (t - B5) + .9375;
		return 7.5625 * (t - B6) * (t - B6) + .984375;
	}
	
	/** Bounce in and out. */
	public static function bounceInOut(t:Number):Number
	{
		if (t < .5)
		{
			t = 1 - t * 2;
			if (t < B1) return (1 - 7.5625 * t * t) / 2;
			if (t < B2) return (1 - (7.5625 * (t - B3) * (t - B3) + .75)) / 2;
			if (t < B4) return (1 - (7.5625 * (t - B5) * (t - B5) + .9375)) / 2;
			return (1 - (7.5625 * (t - B6) * (t - B6) + .984375)) / 2;
		}
		t = t * 2 - 1;
		if (t < B1) return (7.5625 * t * t) / 2 + .5;
		if (t < B2) return (7.5625 * (t - B3) * (t - B3) + .75) / 2 + .5;
		if (t < B4) return (7.5625 * (t - B5) * (t - B5) + .9375) / 2 + .5;
		return (7.5625 * (t - B6) * (t - B6) + .984375) / 2 + .5;
	}
	
	/** Circle in. */
	public static function circIn(t:Number):Number
	{
		return -(Math.sqrt(1 - t * t) - 1);
	}
	
	/** Circle out. */
	public static function circOut(t:Number):Number
	{
		return Math.sqrt(1 - (t - 1) * (t - 1));
	}
	
	/** Circle in and out. */
	public static function circInOut(t:Number):Number
	{
		return t <= .5 ? (Math.sqrt(1 - t * t * 4) - 1) / -2 : (Math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2;
	}
	
	/** Exponential in. */
	public static function expoIn(t:Number):Number
	{
		return Math.pow(2, 10 * (t - 1));
	}
	
	/** Exponential out. */
	public static function expoOut(t:Number):Number
	{
		return -Math.pow(2, -10 * t) + 1;
	}
	
	/** Exponential in and out. */
	public static function expoInOut(t:Number):Number
	{
		return t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
	}
	
	/** Back in. */
	public static function backIn(t:Number):Number
	{
		return t * t * (2.70158 * t - 1.70158);
	}
	
	/** Back out. */
	public static function backOut(t:Number):Number
	{
		return 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
	}
	
	/** Back in and out. */
	public static function backInOut(t:Number):Number
	{
		t *= 2;
		if (t < 1) return t * t * (2.70158 * t - 1.70158) / 2;
		t --;
		return (1 - (--t) * (t) * (-2.70158 * t - 1.70158)) / 2 + .5;
	}
	
	// Easing constants.
	/** @private */ private static const PI:Number = Math.PI;
	/** @private */ private static const PI2:Number = Math.PI / 2;
	/** @private */ private static const EL:Number = 2 * PI / .45;
	/** @private */ private static const B1:Number = 1 / 2.75;
	/** @private */ private static const B2:Number = 2 / 2.75;
	/** @private */ private static const B3:Number = 1.5 / 2.75;
	/** @private */ private static const B4:Number = 2.5 / 2.75;
	/** @private */ private static const B5:Number = 2.25 / 2.75;
	/** @private */ private static const B6:Number = 2.625 / 2.75;
	
	/**
	 * Operation of in/out easers:
	 * 
	 * in(t)
	 *		return t;
	 * out(t)
	 * 		return 1 - in(1 - t);
	 * inOut(t)
	 * 		return (t <= .5) ? in(t * 2) / 2 : out(t * 2 - 1) / 2 + .5;
	 */
}