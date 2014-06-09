package haxepunk.math;

class Math
{

	public static inline var PI = 3.14159265358979323;
	public static inline var EPSILON = 1e-10;

	/**
	 * Flash equivalent: int.MIN_VALUE
	 */
	public static inline var INT_MIN_VALUE = -2147483648;

	/**
	 * Flash equivalent: int.MAX_VALUE
	 */
	public static inline var INT_MAX_VALUE = 2147483647;

	/**
	 * Flash equivalent: Number.MAX_VALUE
	 */
#if flash
	public static var NUMBER_MAX_VALUE(get_NUMBER_MAX_VALUE,never):Float;
	public static inline function get_NUMBER_MAX_VALUE():Float { return untyped __global__["Number"].MAX_VALUE; }
#else
	public static var NUMBER_MAX_VALUE(get_NUMBER_MAX_VALUE,never):Float;
	public static inline function get_NUMBER_MAX_VALUE():Float { return 179 * pow(10, 306); } // 1.79e+308
#end

	// Used for rad-to-deg and deg-to-rad conversion.
	public static var DEG(get, never):Float;
	public static inline function get_DEG(): Float { return 180 / PI; }
	public static var RAD(get, never):Float;
	public static inline function get_RAD(): Float { return PI / 180; }

	public static var POSITIVE_INFINITY(get, never):Float;
	private static inline function get_POSITIVE_INFINITY() { return std.Math.POSITIVE_INFINITY; }

	public static var NEGATIVE_INFINITY(get, never):Float;
	private static inline function get_NEGATIVE_INFINITY() { return std.Math.NEGATIVE_INFINITY; }

	public static var NaN(get, never):Float;
	private static inline function get_NaN() { return std.Math.NaN; }

	// functions from std.Math
	public static inline function isNaN(v:Float):Bool { return std.Math.isNaN(v); }

	public static inline function sin(theta:Float):Float { return std.Math.sin(theta); }
	public static inline function cos(theta:Float):Float { return std.Math.cos(theta); }
	public static inline function tan(theta:Float):Float { return std.Math.tan(theta); }
	public static inline function acos(theta:Float):Float { return std.Math.acos(theta); }
	public static inline function asin(theta:Float):Float { return std.Math.asin(theta); }
	public static inline function atan(theta:Float):Float { return std.Math.atan(theta); }
	public static inline function atan2(dy:Float, dx:Float):Float { return std.Math.atan2(dy, dx); }

	public static inline function sqrt(f:Float) { return std.Math.sqrt(f); }
	public static inline function floor(f:Float) { return std.Math.floor(f); }
	public static inline function ceil(f:Float) { return std.Math.ceil(f); }
	public static inline function round(f:Float) { return std.Math.round(f); }
	public static inline function pow(v:Float, p:Float) { return std.Math.pow(v, p); }

	/**
	 * Round a float to the nearest decimal
	 * @param   num        The number to round,
	 * @param   precision  The decimal place to round to.
	 * @return  The rounded float.
	 */
	public static inline function roundTo(num:Float, precision:Int):Float
	{
		var exp:Float = pow(10, precision);
		return round(num * exp) / exp;
	}

	public static inline function abs(f:Float):Float
	{
		return f < 0 ? -f : f;
	}

	public static inline function max(a:Float, b:Float):Float
	{
		return a < b ? b : a;
	}

	public static inline function min(a:Float, b:Float):Float
	{
		return a > b ? b : a;
	}

	public static inline function clamp(value:Float, min:Float=0, max:Float=1):Float
	{
		return value < min ? min : (value > max ? max : value);
	}

	/**
	 * Finds the sign of the provided value.
	 * @param	value		The Float to evaluate.
	 * @return	1 if value > 0, -1 if value < 0, and 0 when value == 0.
	 */
	public static inline function sign(value:Float):Int
	{
		return value < 0 ? -1 : (value > 0 ? 1 : 0);
	}

	/**
	 * Linear interpolation between two values.
	 * @param	a		First value.
	 * @param	b		Second value.
	 * @param	t		Interpolation factor.
	 * @return	When t=0, returns a. When t=1, returns b. When t=0.5, will return halfway between a and b. Etc.
	 */
	public inline static function lerp(a:Float, b:Float, t:Float=1):Float
	{
		return a + (b - a) * t;
	}

	/**
	 * Linear interpolation between two colors.
	 * @param	fromColor		First color.
	 * @param	toColor			Second color.
	 * @param	t				Interpolation value. Clamped to the range [0, 1].
	 * return	RGB component-interpolated color value.
	 */
	public static inline function colorLerp(fromColor:Int, toColor:Int, t:Float = 1):Int
	{
		if (t <= 0)
		{
			return fromColor;
		}
		else if (t >= 1)
		{
			return toColor;
		}
		else
		{
			var a:Int = fromColor >> 24 & 0xFF,
				r:Int = fromColor >> 16 & 0xFF,
				g:Int = fromColor >> 8 & 0xFF,
				b:Int = fromColor & 0xFF,
				dA:Int = (toColor >> 24 & 0xFF) - a,
				dR:Int = (toColor >> 16 & 0xFF) - r,
				dG:Int = (toColor >> 8 & 0xFF) - g,
				dB:Int = (toColor & 0xFF) - b;
			a += Std.int(dA * t);
			r += Std.int(dR * t);
			g += Std.int(dG * t);
			b += Std.int(dB * t);
			return a << 24 | r << 16 | g << 8 | b;
		}
	}

	/**
	 * Finds the angle (in degrees) from point 1 to point 2.
	 * @param	x1		The first x-position.
	 * @param	y1		The first y-position.
	 * @param	x2		The second x-position.
	 * @param	y2		The second y-position.
	 * @return	The angle from (x1, y1) to (x2, y2).
	 */
	public static inline function angle(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		var a:Float = atan2(y2 - y1, x2 - x1) * DEG;
		return a < 0 ? a + 360 : a;
	}

	/**
	 * Get difference between two angles. Result will be between -180 and 180.
	 * @param	angle1	First angle, in degrees.
	 * @param	angle2	Second angle, in degrees.
	 * @return	The angle difference, in degrees.
	 */
	public static inline function angleDifference(angle1:Float, angle2:Float):Float
	{
		var diff:Float = angle2 - angle1;
		while (diff < -180) diff += 360;
		while (diff > 180) diff -= 360;
		return diff;
	}

	/**
	 * Find the squared distance between two points.
	 * @param	x1		The first x-position.
	 * @param	y1		The first y-position.
	 * @param	x2		The second x-position.
	 * @param	y2		The second y-position.
	 * @return	The squared distance.
	 */
	public static inline function distanceSquared(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float
	{
		return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
	}

	/**
	 * Find the distance between two points.
	 * @param	x1		The first x-position.
	 * @param	y1		The first y-position.
	 * @param	x2		The second x-position.
	 * @param	y2		The second y-position.
	 * @return	The distance.
	 */
	public static inline function distance(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float
	{
		return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
	}

	/**
	 * Find the distance between two rectangles. Will return 0 if the rectangles overlap.
	 * @param	x1		The x-position of the first rect.
	 * @param	y1		The y-position of the first rect.
	 * @param	w1		The width of the first rect.
	 * @param	h1		The height of the first rect.
	 * @param	x2		The x-position of the second rect.
	 * @param	y2		The y-position of the second rect.
	 * @param	w2		The width of the second rect.
	 * @param	h2		The height of the second rect.
	 * @return	The distance.
	 */
	public static function distanceRects(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Float
	{
		if (x1 < x2 + w2 && x2 < x1 + w1)
		{
			if (y1 < y2 + h2 && y2 < y1 + h1) return 0;
			if (y1 > y2) return y1 - (y2 + h2);
			return y2 - (y1 + h1);
		}
		if (y1 < y2 + h2 && y2 < y1 + h1)
		{
			if (x1 > x2) return x1 - (x2 + w2);
			return x2 - (x1 + w1);
		}
		if (x1 > x2)
		{
			if (y1 > y2) return distance(x1, y1, (x2 + w2), (y2 + h2));
			return distance(x1, y1 + h1, x2 + w2, y2);
		}
		if (y1 > y2) return distance(x1 + w1, y1, x2, y2 + h2);
		return distance(x1 + w1, y1 + h1, x2, y2);
	}

	/**
	 * Find the distance between a point and a rectangle. Returns 0 if the point is within the rectangle.
	 * @param	px		The x-position of the point.
	 * @param	py		The y-position of the point.
	 * @param	rx		The x-position of the rect.
	 * @param	ry		The y-position of the rect.
	 * @param	rw		The width of the rect.
	 * @param	rh		The height of the rect.
	 * @return	The distance.
	 */
	public static function distanceRectPoint(px:Float, py:Float, rx:Float, ry:Float, rw:Float, rh:Float):Float
	{
		if (px >= rx && px <= rx + rw)
		{
			if (py >= ry && py <= ry + rh) return 0;
			if (py > ry) return py - (ry + rh);
			return ry - py;
		}
		if (py >= ry && py <= ry + rh)
		{
			if (px > rx) return px - (rx + rw);
			return rx - px;
		}
		if (px > rx)
		{
			if (py > ry) return distance(px, py, rx + rw, ry + rh);
			return distance(px, py, rx + rw, ry);
		}
		if (py > ry) return distance(px, py, rx, ry + rh);
		return distance(px, py, rx, ry);
	}

	/**
	 * Transfers a value from one scale to another scale. For example, scale(.5, 0, 1, 10, 20) == 15, and scale(3, 0, 5, 100, 0) == 40.
	 * @param	value		The value on the first scale.
	 * @param	min			The minimum range of the first scale.
	 * @param	max			The maximum range of the first scale.
	 * @param	min2		The minimum range of the second scale.
	 * @param	max2		The maximum range of the second scale.
	 * @return	The scaled value.
	 */
	public static inline function scale(value:Float, min:Float, max:Float, min2:Float, max2:Float):Float
	{
		return min2 + ((value - min) / (max - min)) * (max2 - min2);
	}

	/**
	 * Transfers a value from one scale to another scale, but clamps the return value within the second scale.
	 * @param	value		The value on the first scale.
	 * @param	min			The minimum range of the first scale.
	 * @param	max			The maximum range of the first scale.
	 * @param	min2		The minimum range of the second scale.
	 * @param	max2		The maximum range of the second scale.
	 * @return	The scaled and clamped value.
	 */
	public static function scaleClamp(value:Float, min:Float, max:Float, min2:Float, max2:Float):Float
	{
		value = min2 + ((value - min) / (max - min)) * (max2 - min2);
		if (max2 > min2)
		{
			value = value < max2 ? value : max2;
			return value > min2 ? value : min2;
		}
		value = value < min2 ? value : min2;
		return value > max2 ? value : max2;
	}

	/**
	 * Swaps the current item between a and b. Useful for quick state/string/value swapping.
	 * @param	current		The currently selected item.
	 * @param	a			Item a.
	 * @param	b			Item b.
	 * @return	Returns a if current is b, and b if current is a.
	 */
	public static inline function swap<T>(current:T, a:T, b:T):T
	{
		return current == a ? b : a;
	}

	/**
	 * The random seed used by HXP's random functions.
	 */
	public static var randomSeed(default, set):Int = 0;
	private static inline function set_randomSeed(value:Int):Int
	{
		_seed = Std.int(clamp(value, 1.0, INT_MAX_VALUE - 1));
		randomSeed = _seed;
		return _seed;
	}

	/**
	 * A pseudo-random Float produced using HXP's random seed, where 0 <= Float < 1.
	 */
	public static var random(get, null):Float;
	private static inline function get_random():Float
	{
		_seed = Std.int((_seed * 16807.0) % INT_MAX_VALUE);
		return _seed / INT_MAX_VALUE;
	}

	/**
	 * Returns a pseudo-random Int.
	 * @param	amount		The returned Int will always be 0 <= Int < amount.
	 * @return	The Int.
	 */
	public static inline function rand(amount:Int):Int
	{
		_seed = Std.int((_seed * 16807.0) % INT_MAX_VALUE);
		return Std.int((_seed / INT_MAX_VALUE) * amount);
	}

	// Pseudo-random number generation.
	private static var _seed:Int = 0;

}
