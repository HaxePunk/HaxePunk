package haxepunk.utils;

/**
 * This class is for math utility functions previously stored in HXP.
 * @since	4.0.0
 */
class MathUtil
{
#if flash
	public static var NUMBER_MAX_VALUE(get_NUMBER_MAX_VALUE,never):Float;
	public static inline function get_NUMBER_MAX_VALUE():Float { return untyped __global__["Number"].MAX_VALUE; }
#else
	public static var NUMBER_MAX_VALUE(get_NUMBER_MAX_VALUE,never):Float;
	public static inline function get_NUMBER_MAX_VALUE():Float { return 179 * Math.pow(10, 306); } // 1.79e+308
#end

	// Used for rad-to-deg and deg-to-rad conversion.
	public static var DEG(get, never):Float;
	public static inline function get_DEG(): Float { return -180 / Math.PI; }
	public static var RAD(get, never):Float;
	public static inline function get_RAD(): Float { return Math.PI / -180; }

	public static inline var INT_MIN_VALUE = -2147483648;
	public static inline var INT_MAX_VALUE = 2147483647;
	public static inline var PI = 3.14159265358979323;
	public static inline var EPSILON = 1e-10;

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
	 * Approaches the value towards the target, by the specified amount, without overshooting the target.
	 * @param	value	The starting value.
	 * @param	target	The target that you want value to approach.
	 * @param	amount	How much you want the value to approach target by.
	 * @return	The new value.
	 */
	public static inline function approach(value:Float, target:Float, amount:Float):Float
	{
		if (value < target - amount)
		{
			return value + amount;
		}
		else if (value > target + amount)
		{
			return value - amount;
		}
		else
		{
			return target;
		}
	}

	/**
	 * Linear interpolation between two values.
	 * @param	a		First value.
	 * @param	b		Second value.
	 * @param	t		Interpolation factor.
	 * @return	When t=0, returns a. When t=1, returns b. When t=0.5, will return halfway between a and b. Etc.
	 */
	public static inline function lerp(a:Float, b:Float, t:Float = 1):Float
	{
		return a + (b - a) * t;
	}

	/**
	 * Steps the object towards a point.
	 * @param	object		Object to move (must have an x and y property).
	 * @param	x			X position to step towards.
	 * @param	y			Y position to step towards.
	 * @param	distance	The distance to step (will not overshoot target).
	 */
	public static function stepTowards(object:Position, x:Float, y:Float, distance:Float = 1)
	{
		point.x = x - object.x;
		point.y = y - object.y;
		if (point.length <= distance)
		{
			object.x = x;
			object.y = y;
			return;
		}
		point.normalize(distance);
		object.x += point.x;
		object.y += point.y;
	}

	/**
	 * Anchors the object to a position.
	 * @param	object		The object to anchor.
	 * @param	anchor		The anchor object.
	 * @param	distance	The max distance object can be anchored to the anchor.
	 */
	public static inline function anchorTo(object:Position, anchor:Position, distance:Float = 0)
	{
		point.x = object.x - anchor.x;
		point.y = object.y - anchor.y;
		if (point.length > distance) point.normalize(distance);
		object.x = anchor.x + point.x;
		object.y = anchor.y + point.y;
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
		var a:Float = Math.atan2(y2 - y1, x2 - x1) * DEG;
		return a < 0 ? a + 360 : a;
	}

	/**
	 * Sets the x/y values of the provided object to a vector of the specified angle and length.
	 * @param	object		The object whose x/y properties should be set.
	 * @param	angle		The angle of the vector, in degrees.
	 * @param	length		The distance to the vector from (0, 0).
	 * @param	x			X offset.
	 * @param	y			Y offset.
	 */
	public static inline function angleXY(object:Position, angle:Float, length:Float = 1, x:Float = 0, y:Float = 0)
	{
		angle *= RAD;
		object.x = Math.cos(angle) * length + x;
		object.y = Math.sin(angle) * length + y;
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
	 * Rotates the object around the anchor by the specified amount.
	 * @param	object		Object to rotate around the anchor.
	 * @param	anchor		Anchor to rotate around.
	 * @param	angle		The amount of degrees to rotate by.
	 * @param	relative	If the angle is relative to the angle between the object and the anchor.
	 */
	public static inline function rotateAround(object:Position, anchor:Position, angle:Float = 0, relative:Bool = true)
	{
		if (relative) angle += MathUtil.angle(anchor.x, anchor.y, object.x, object.y);
		angleXY(object, angle, distance(anchor.x, anchor.y, object.x, object.y), anchor.x, anchor.y);
	}

	/**
	 * Round a float to the nearest decimal
	 * @param   num        The number to round,
	 * @param   precision  The decimal place to round to.
	 * @return  The rounded float.
	 */
	public static inline function roundTo(num:Float, precision:Int=0):Float
	{
		var exp:Float = Math.pow(10, precision);
		return std.Math.round(num * exp) / exp;
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
	 * Clamps the value within the minimum and maximum values.
	 * @param	value		The Float to evaluate.
	 * @param	min			The minimum range.
	 * @param	max			The maximum range.
	 * @return	The clamped value.
	 */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		if (max > min)
		{
			if (value < min) return min;
			else if (value > max) return max;
			else return value;
		}
		else
		{
			// Min/max swapped
			if (value < max) return max;
			else if (value > min) return min;
			else return value;
		}
	}

	public static function iclamp(value:Int, min:Int, max:Int):Int
	{
		if (max > min)
		{
			if (value < min) return min;
			else if (value > max) return max;
			else return value;
		}
		else
		{
			// Min/max swapped
			if (value < max) return max;
			else if (value > min) return min;
			else return value;
		}
	}

	/**
	 * Clamps the object inside the rectangle.
	 * @param	object		The object to clamp (must have an x and y property).
	 * @param	x			Rectangle's x.
	 * @param	y			Rectangle's y.
	 * @param	width		Rectangle's width.
	 * @param	height		Rectangle's height.
	 * @param	padding		Rectangle's padding.
	 */
	public static inline function clampInRect(object:Position, x:Float, y:Float, width:Float, height:Float, padding:Float = 0)
	{
		object.x = clamp(object.x, x + padding, x + width - padding);
		object.y = clamp(object.y, y + padding, y + height - padding);
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

	public static inline function iround(f:Float):Int return Std.int(Math.round(f));

	public static inline function abs(f:Float):Float return f < 0 ? -f : f;
	public static inline function iabs(i:Int):Int return i < 0 ? -i : i;

	public static inline function max(a:Float, b:Float):Float return a < b ? b : a;
	public static inline function min(a:Float, b:Float):Float return a > b ? b : a;
	public static inline function imax(a:Int, b:Int):Int return a < b ? b : a;
	public static inline function imin(a:Int, b:Int):Int return a > b ? b : a;

	public static inline function sin(theta:Float):Float return std.Math.sin(theta);
	public static inline function cos(theta:Float):Float return std.Math.cos(theta);
	public static inline function tan(theta:Float):Float return std.Math.tan(theta);
	public static inline function acos(theta:Float):Float return std.Math.acos(theta);
	public static inline function asin(theta:Float):Float return std.Math.asin(theta);
	public static inline function atan(theta:Float):Float return std.Math.atan(theta);
	public static inline function atan2(dy:Float, dx:Float):Float return std.Math.atan2(dy, dx);

	public static inline function sqrt(f:Float) return std.Math.sqrt(f);
	public static inline function floor(f:Float) return std.Math.floor(f);
	public static inline function ceil(f:Float) return std.Math.ceil(f);
	public static inline function random() return std.Math.random();
	public static inline function round(f:Float) return std.Math.round(f);
	public static inline function roundDecimal(f:Float, places:Int) return Std.int(f * Math.pow(10, places)) / Math.pow(10, places);
	public static inline function pow(v:Float, p:Float) return std.Math.pow(v, p);
	public static inline function log(v:Float) return std.Math.log(v);

	static var point:Position = new Position();
}
