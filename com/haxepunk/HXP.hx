package com.haxepunk;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
#if flash
import flash.media.SoundMixer;
#end
import flash.media.SoundTransform;
import flash.system.System;
import flash.utils.ByteArray;

#if nme
import nme.Assets;
#else
import openfl.Assets;
#end

import com.haxepunk.Graphic;
import com.haxepunk.Tween;
import com.haxepunk.debug.Console;
import com.haxepunk.tweens.misc.Alarm;
import com.haxepunk.tweens.misc.MultiVarTween;
import com.haxepunk.utils.Ease;

import haxe.EnumFlags;
import haxe.Timer;

/**
 * Static catch-all class used to access global properties and functions.
 */
class HXP
{
	/**
	 * The HaxePunk major version.
	 */
	public static inline var VERSION:String = "2.3.2";

	/**
	 * The standard layer used since only flash can handle negative indicies in arrays, set your layers to some offset of this
	 */
	public static inline var BASELAYER:Int = 10;

	/**
	 * Flash equivalent: Number.MAX_VALUE
	 */
#if flash
	public static var NUMBER_MAX_VALUE(get_NUMBER_MAX_VALUE,never): Float;
	public static inline function get_NUMBER_MAX_VALUE(): Float { return untyped __global__["Number"].MAX_VALUE; }
#else
	public static var NUMBER_MAX_VALUE(get_NUMBER_MAX_VALUE,never): Float;
	public static inline function get_NUMBER_MAX_VALUE(): Float { return 179 * Math.pow(10, 306); } // 1.79e+308
#end

	/**
	 * Flash equivalent: int.MAX_VALUE
	 */
#if (!haxe3 && neko)
	public static inline var INT_MAX_VALUE = 1073741823;
#else
	public static inline var INT_MAX_VALUE = 2147483646;
#end

	/**
	 * The color black defined for neko (BitmapInt32) or flash (Int)
	 */
#if (!haxe3 && neko)
	public static inline var blackColor = { rgb: 0x000000, a: 0 }; // BitmapInt32
#else
	public static inline var blackColor = 0x00000000;
#end

	/**
	 * Width of the game.
	 */
	public static var width:Int;

	/**
	 * Height of the game.
	 */
	public static var height:Int;

	/**
	 * Width of the window.
	 */
	public static var windowWidth:Int;

	/**
	 * Height of the window.
	 */
	public static var windowHeight:Int;

	/**
	 * If the game is running at a fixed framerate.
	 */
	public static var fixed:Bool;

	/**
	 * The framerate assigned to the stage.
	 */
	public static var frameRate:Float = 0;

	/**
	 * The framerate assigned to the stage.
	 */
	public static var assignedFrameRate:Float;

	/**
	 * Time elapsed since the last frame (non-fixed framerate only).
	 */
	public static var elapsed:Float;

	/**
	 * Timescale applied to HXP.elapsed (non-fixed framerate only).
	 */
	public static var rate:Float = 1;

	/**
	 * The Screen object, use to transform or offset the Screen.
	 */
	public static var screen:Screen;

	/**
	 * The current screen buffer, drawn to in the render loop.
	 */
	public static var buffer:BitmapData;

	/**
	 * A rectangle representing the size of the screen.
	 */
	public static var bounds:Rectangle;

	/**
	 * The default font file to use
	 */
#if (openfl || nme)
	public static var defaultFont:String = "font/04B_03__.ttf";
#else
	public static var defaultFont:String = "default";
#end

	/**
	 * Point used to determine drawing offset in the render loop.
	 */
	public static var camera:Point = new Point();

	/**
	 * Global tweener for tweening between multiple scenes
	 */
	public static var tweener:Tweener = new Tweener();

	/**
	 * Whether the game has focus or not
	 */
	public static var focused:Bool = false;

	/**
	 * Half the screen width.
	 */
	public static var halfWidth(default, null):Float;

	/**
	 * Half the screen height.
	 */
	public static var halfHeight(default, null):Float;

	/**
	 * Defines how to render the scene
	 */
	public static var renderMode:EnumFlags<RenderMode>;

	/**
	 * Defines the allowed orientations
	 */
	public static var orientations:Array<Int> = [];

	/**
	 * The currently active World object (deprecated)
	 */
	public static var world(get_world, set_world):Scene;
	private static inline function get_world():Scene
	{
		HXP.log('HXP.world is deprecated, please use HXP.scene instead');
		return _scene;
	}
	private static inline function set_world(value:Scene):Scene
	{
		HXP.log('HXP.world is deprecated, please use HXP.scene instead');
		return set_scene(value);
	}

	/**
	 * The currently active Scene object. When you set this, the Scene is flagged
	 * to switch, but won't actually do so until the end of the current frame.
	 */
	public static var scene(get_scene, set_scene):Scene;
	private static inline function get_scene():Scene { return _scene; }
	private static function set_scene(value:Scene):Scene
	{
		if (_goto != null)
		{
			if (_goto == value) return value;
		}
		else
		{
			if (_scene == value) return value;
		}
		_goto = value;
		return _scene;
	}

	public static inline function swapScene()
	{
		_scene = _goto;
		_goto = null;
	}

	/**
	 * Resize the screen.
	 * @param width		New width.
	 * @param height	New height.
	 */
	public static function resize(width:Int, height:Int)
	{
		// resize scene to scale
		width = Std.int(width / HXP.screen.fullScaleX);
		height = Std.int(height / HXP.screen.fullScaleY);
		HXP.width = width;
		HXP.height = height;
		HXP.halfWidth = width / 2;
		HXP.halfHeight = height / 2;
		HXP.bounds.width = width;
		HXP.bounds.height = height;
		HXP.screen.resize();
	}

	/**
	 * Empties an array of its' contents
	 * @param array filled array
	 */
	public static inline function clear(array:Array<Dynamic>)
	{
#if (cpp || php)
		array.splice(0, array.length);
#else
		untyped array.length = 0;
#end
	}

	/**
	 * Sets the camera position.
	 * @param	x	X position.
	 * @param	y	Y position.
	 */
	public static inline function setCamera(x:Float = 0, y:Float = 0)
	{
		camera.x = x;
		camera.y = y;
	}

	/**
	 * Resets the camera position.
	 */
	public static inline function resetCamera()
	{
		camera.x = camera.y = 0;
	}

	/**
	 * Toggles between windowed and fullscreen modes
	 */
	public static var fullscreen(get_fullscreen, set_fullscreen):Bool;
	private static inline function get_fullscreen():Bool { return HXP.stage.displayState == StageDisplayState.FULL_SCREEN; }
	private static inline function set_fullscreen(value:Bool):Bool
	{
		if (value) HXP.stage.displayState = StageDisplayState.FULL_SCREEN;
		else HXP.stage.displayState = StageDisplayState.NORMAL;
		return value;
	}

	/**
	 * Global volume factor for all sounds, a value from 0 to 1.
	 */
	public static var volume(get_volume, set_volume):Float;
	private static inline function get_volume():Float { return _volume; }
	private static function set_volume(value:Float):Float
	{
		if (value < 0) value = 0;
		if (_volume == value) return value;
		_soundTransform.volume = _volume = value;
		#if flash
		SoundMixer.soundTransform = _soundTransform;
		#end
		return _volume;
	}

	/**
	 * Global panning factor for all sounds, a value from -1 to 1.
	 */
	public static var pan(get_pan, set_pan):Float;
	private static inline function get_pan():Float { return _pan; }
	private static function set_pan(value:Float):Float
	{
		if (value < -1) value = -1;
		if (value > 1) value = 1;
		if (_pan == value) return value;
		_soundTransform.pan = _pan = value;
		#if flash
		SoundMixer.soundTransform = _soundTransform;
		#end
		return _pan;
	}

	/**
	 * Randomly chooses and returns one of the provided values.
	 * @param	objs		The Objects you want to randomly choose from. Can be ints, Floats, Points, etc.
	 * @return	A randomly chosen one of the provided parameters.
	 */
	public static inline function choose(objs:Array<Dynamic>):Dynamic
	{
		return objs[rand(objs.length)];
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
	 * Approaches the value towards the target, by the specified amount, without overshooting the target.
	 * @param	value	The starting value.
	 * @param	target	The target that you want value to approach.
	 * @param	amount	How much you want the value to approach target by.
	 * @return	The new value.
	 */
	public static inline function approach(value:Float, target:Float, amount:Float):Float
	{
		if (value < target - amount) {
			return value + amount;
		} else if (value > target + amount) {
			return value - amount;
		} else {
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
	 * Linear interpolation between two colors.
	 * @param	fromColor		First color.
	 * @param	toColor			Second color.
	 * @param	t				Interpolation value. Clamped to the range [0, 1].
	 * return	RGB component-interpolated color value.
	 */
	public static inline function colorLerp(fromColor:Int, toColor:Int, t:Float = 1):Int
	{
		if (t <= 0) { return fromColor; }
		else if (t >= 1) { return toColor; }
		else {
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
	 * Steps the object towards a point.
	 * @param	object		Object to move (must have an x and y property).
	 * @param	x			X position to step towards.
	 * @param	y			Y position to step towards.
	 * @param	distance	The distance to step (will not overshoot target).
	 */
	public static function stepTowards(object:Dynamic, x:Float, y:Float, distance:Float = 1)
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
	public static inline function anchorTo(object:Dynamic, anchor:Dynamic, distance:Float = 0)
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
	public static inline function angleXY(object:Dynamic, angle:Float, length:Float = 1, x:Float = 0, y:Float = 0)
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
	 */
	public static inline function rotateAround(object:Dynamic, anchor:Dynamic, angle:Float = 0, relative:Bool = true)
	{
		if (relative) angle += HXP.angle(anchor.x, anchor.y, object.x, object.y);
		HXP.angleXY(object, angle, HXP.distance(anchor.x, anchor.y, object.x, object.y), anchor.x, anchor.y);
	}

	/**
	 * Round a float to the nearest decimal
	 * @param   num        The number to round,
	 * @param   precision  The decimal place to round to.
	 * @return  The rounded float.
	 */
	public static inline function round(num:Float, precision:Int):Float
	{
		var exp:Float = Math.pow(10, precision);
		return Math.round(num * exp) / exp;
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

	/**
	 * Clamps the object inside the rectangle.
	 * @param	object		The object to clamp (must have an x and y property).
	 * @param	x			Rectangle's x.
	 * @param	y			Rectangle's y.
	 * @param	width		Rectangle's width.
	 * @param	height		Rectangle's height.
	 */
	public static inline function clampInRect(object:Dynamic, x:Float, y:Float, width:Float, height:Float, padding:Float = 0)
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

	/**
	 * The random seed used by FP's random functions.
	 */
	public static var randomSeed(default, set_randomSeed):Int;
	private static inline function set_randomSeed(value:Int):Int
	{
		_seed = Std.int(clamp(value, 1.0, INT_MAX_VALUE));
		randomSeed = _seed;
		return _seed;
	}

	/**
	 * Randomizes the random seed using Flash's Math.random() function.
	 */
	public static inline function randomizeSeed()
	{
		randomSeed = Std.int(INT_MAX_VALUE * Math.random());
	}

	/**
	 * A pseudo-random Float produced using FP's random seed, where 0 <= Float < 1.
	 */
	public static var random(get_random, null):Float;
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

	private static function indexOf<T>(a:Array<T>, v:T):Int
	{
		var i = 0;
		for( v2 in a ) {
			if( v == v2 )
				return i;
			i++;
		}
		return -1;
	}

	/**
	 * Returns the next item after current in the list of options.
	 * @param	current		The currently selected item (must be one of the options).
	 * @param	options		An array of all the items to cycle through.
	 * @param	loop		If true, will jump to the first item after the last item is reached.
	 * @return	The next item in the list.
	 */
	public static inline function next<T>(current:T, options:Array<T>, loop:Bool = true):Dynamic
	{
		if (loop)
			return options[(indexOf(options, current) + 1) % options.length];
		else
			return options[Std.int(Math.max(indexOf(options, current) + 1, options.length - 1))];
	}

	/**
	 * Returns the item previous to the current in the list of options.
	 * @param	current		The currently selected item (must be one of the options).
	 * @param	options		An array of all the items to cycle through.
	 * @param	loop		If true, will jump to the last item after the first is reached.
	 * @return	The previous item in the list.
	 */
	public static inline function prev<T>(current:T, options:Array<T>, loop:Bool = true):Dynamic
	{
		if (loop)
			return options[((indexOf(options, current) - 1) + options.length) % options.length];
		else
			return options[Std.int(Math.max(indexOf(options, current) - 1, 0))];
	}

	/**
	 * Swaps the current item between a and b. Useful for quick state/string/value swapping.
	 * @param	current		The currently selected item.
	 * @param	a			Item a.
	 * @param	b			Item b.
	 * @return	Returns a if current is b, and b if current is a.
	 */
	public static inline function swap(current:Dynamic, a:Dynamic, b:Dynamic):Dynamic
	{
		return current == a ? b : a;
	}

	/**
	 * Creates a color value by combining the chosen RGB values.
	 * @param	R		The red value of the color, from 0 to 255.
	 * @param	G		The green value of the color, from 0 to 255.
	 * @param	B		The blue value of the color, from 0 to 255.
	 * @return	The color Int.
	 */
	public static inline function getColorRGB(R:Int = 0, G:Int = 0, B:Int = 0):Int
	{
		return R << 16 | G << 8 | B;
	}

	/**
	 * Creates a color value with the chosen HSV values.
	 * @param	h		The hue of the color (from 0 to 1).
	 * @param	s		The saturation of the color (from 0 to 1).
	 * @param	v		The value of the color (from 0 to 1).
	 * @return	The color Int.
	 */
	public static function getColorHSV(h:Float, s:Float, v:Float):Int
	{
		h = Std.int(h * 360);
		var hi:Int = Math.floor(h / 60) % 6,
			f:Float = h / 60 - Math.floor(h / 60),
			p:Float = (v * (1 - s)),
			q:Float = (v * (1 - f * s)),
			t:Float = (v * (1 - (1 - f) * s));
		switch (hi)
		{
			case 0: return Std.int(v * 255) << 16 | Std.int(t * 255) << 8 | Std.int(p * 255);
			case 1: return Std.int(q * 255) << 16 | Std.int(v * 255) << 8 | Std.int(p * 255);
			case 2: return Std.int(p * 255) << 16 | Std.int(v * 255) << 8 | Std.int(t * 255);
			case 3: return Std.int(p * 255) << 16 | Std.int(q * 255) << 8 | Std.int(v * 255);
			case 4: return Std.int(t * 255) << 16 | Std.int(p * 255) << 8 | Std.int(v * 255);
			case 5: return Std.int(v * 255) << 16 | Std.int(p * 255) << 8 | Std.int(q * 255);
			default: return 0;
		}
		return 0;
	}

	/**
	 * Finds the hue factor of a color.
	 * @param  color The color to evaluate.
	 * @return The hue value (from 0 to 1).
	 */
	public static function getColorHue(color:Int):Float
	{
		var h:Int = (color >> 16) & 0xFF;
		var s:Int = (color >> 8) & 0xFF;
		var v:Int = color & 0xFF;

		var max:Int = Std.int(Math.max(h, Math.max(s, v)));
		var min:Int = Std.int(Math.min(h, Math.min(s, v)));

		var hue:Float = 0;

		if (max == min) {
			hue = 0;
		} else if (max == h) {
			hue = (60 * (s - v) / (max - min) + 360) % 360;
		} else if (max == s) {
			hue = (60 * (v - h) / (max - min) + 120);
		} else if (max == v) {
			hue = (60 * (h - s) / (max - min) + 240);
		}

		return hue / 360;
	}

	/**
	 * Finds the saturation factor of a color.
	 * @param  color The color to evaluate.
	 * @return The saturation value (from 0 to 1).
	 */
	public static function getColorSaturation(color:Int):Float
	{
		var h:Int = (color >> 16) & 0xFF;
		var s:Int = (color >> 8) & 0xFF;
		var v:Int = color & 0xFF;

		var max:Int = Std.int(Math.max(h, Math.max(s, v)));

		if (max == 0) {
			return 0;
		} else {
			var min:Int = Std.int(Math.min(h, Math.min(s, v)));

			return (max - min) / max;
		}
	}

	/**
	 * Finds the value factor of a color.
	 * @param  color The color to evaluate.
	 * @return The value value (from 0 to 1).
	 */
	public static function getColorValue(color:Int):Float
	{
		var h:Int = (color >> 16) & 0xFF;
		var s:Int = (color >> 8) & 0xFF;
		var v:Int = color & 0xFF;

		return Std.int(Math.max(h, Math.max(s, v))) / 255;
	}

	/**
	 * Finds the red factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getRed(color:Int):Int
	{
		return color >> 16 & 0xFF;
	}

	/**
	 * Finds the green factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getGreen(color:Int):Int
	{
		return color >> 8 & 0xFF;
	}

	/**
	 * Finds the blue factor of a color.
	 * @param	color		The color to evaluate.
	 * @return	A Int from 0 to 255.
	 */
	public static inline function getBlue(color:Int):Int
	{
		return color & 0xFF;
	}

	/**
	 * Fetches a stored BitmapData object represented by the source.
	 * @param	source		Embedded Bitmap class.
	 * @return	The stored BitmapData object.
	 */
	public static function getBitmap(source:Dynamic):BitmapData
	{
		var name:String = Std.string(source);
		if (_bitmap.exists(name))
			return _bitmap.get(name);

#if (openfl || nme)
		var data:BitmapData = Assets.getBitmapData(source);
#else
		var data:BitmapData = source.bitmapData;
#end
		if (data != null)
			_bitmap.set(name, data);

		return data;
	}

	/**
	 * Creates BitmapData based on platform specifics
	 */
	public static function createBitmap(width:Int, height:Int, ?transparent:Bool = false, ?color:Int = 0):BitmapData
	{
#if flash
	#if flash8
		var sizeError:Bool = (width > 2880 || height > 2880);
	#else
		var sizeError:Bool = (width * height > 16777215 || width > 8191 || height > 8191); // flash 10 requires size to be under 16,777,215
	#end
		if (sizeError)
		{
			trace("BitmapData is too large (" + width + ", " + height + ")");
			return null;
		}
#end // flash

		return new BitmapData(width, height, transparent, HXP.convertColor(color));
	}

	/**
	 * Converts a color to platform specific type (BitmapInt32)
	 */
	public static inline function convertColor(color:Int):Dynamic
	{
#if (!haxe3 && neko)
		return { rgb: color & 0x00FFFFFF, a: color >> 24 };
#else
		return color; // do nothing
#end
	}

	/**
	 * Sets a time flag.
	 * @return	Time elapsed (in milliseconds) since the last time flag was set.
	 */
	public static inline function timeFlag():Float
	{
		var t:Float = Timer.stamp(),
			e:Float = t - _time;
		_time = t;
		return e;
	}

	/**
	 * The global Console object.
	 */
	public static var console(get_console, never):Console;
	private static inline function get_console():Console
	{
		if (_console == null) _console = new Console();
		return _console;
	}

	/**
	 * Checks if the console is enabled.
	 */
	public static function consoleEnabled()
	{
		return _console != null;
	}

	/**
	 * Logs data to the console.
	 * @param	...data		The data parameters to log, can be variables, objects, etc. Parameters will be separated by a space (" ").
	 */
	public static var log:Dynamic = Reflect.makeVarArgs(function(data:Array<Dynamic>)
	{
		if (_console != null)
		{
			_console.log(data);
		}
	});

	/**
	 * Adds properties to watch in the console's debug panel.
	 * @param	...properties		The properties (strings) to watch.
	 */
	public static var watch:Dynamic = Reflect.makeVarArgs(function(properties:Array<Dynamic>)
	{
		if (_console != null)
		{
			_console.watch(properties);
		}
	});

	/**
	 * Tweens numeric public properties of an Object. Shorthand for creating a MultiVarTween tween, starting it and adding it to a Tweener.
	 * @param	object		The object containing the properties to tween.
	 * @param	values		An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 * @param	options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * 						tweener		The Tweener to add this Tween to.
	 * @return	The added MultiVarTween object.
	 *
	 * Example: HXP.tween(object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, complete: onComplete } );
	 */
	public static function tween(object:Dynamic, values:Dynamic, duration:Float, options:Dynamic = null):MultiVarTween
	{
		if (options != null && Reflect.hasField(options, "delay"))
		{
			var delay:Float = options.delay;
			Reflect.deleteField( options, "delay" );
			HXP.alarm(delay, function (o:Dynamic):Void { HXP.tween(object, values, duration, options); });
			return null;
		}

		var type:TweenType = TweenType.OneShot,
			complete:CompleteCallback = null,
			ease:EaseFunction = null,
			tweener:Tweener = HXP.tweener;
		if (Std.is(object, Tweener)) tweener = cast(object, Tweener);
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
			if (Reflect.hasField(options, "tweener")) tweener = options.tweener;
		}
		var tween:MultiVarTween = new MultiVarTween(complete, type);
		tween.tween(object, values, duration, ease);
		tweener.addTween(tween);
		return tween;
	}

	/**
	 * Schedules a callback for the future. Shorthand for creating an Alarm tween, starting it and adding it to a Tweener.
	 * @param	delay		The duration to wait before calling the callback.
	 * @param	complete	The function to be called when complete.
	 * @param	type		Tween type.
	 * @param	tweener		The Tweener object to add this Alarm to. Defaults to HXP.tweener.
	 * @return	The added Alarm object.
	 *
	 * Example: HXP.alarm(5.0, callbackFunction, TweenType.Looping); // Calls callbackFunction every 5 seconds
	 */
	public static function alarm(delay:Float, complete:CompleteCallback, ?type:TweenType = null, tweener:Tweener = null):Alarm
	{
		if (type == null) type = TweenType.OneShot;
		if (tweener == null) tweener = HXP.tweener;

		var alarm:Alarm = new Alarm(delay, complete, type);
		tweener.addTween(alarm, true);
		return alarm;
	}

	/**
	 * Gets an array of frame indices.
	 * @param	from	Starting frame.
	 * @param	to		Ending frame.
	 * @param	skip	Skip amount every frame (eg. use 1 for every 2nd frame).
	 */
	public static function frames(from:Int, to:Int, skip:Int = 0):Array<Int>
	{
		var a:Array<Int> = new Array<Int>();
		skip ++;
		if (from < to)
		{
			while (from <= to)
			{
				a.push(from);
				from += skip;
			}
		}
		else
		{
			while (from >= to)
			{
				a.push(from);
				from -= skip;
			}
		}
		return a;
	}

	/**
	 * Shuffles the elements in the array.
	 * @param	a		The Object to shuffle (an Array or Vector).
	 */
	public static function shuffle(a:Dynamic)
	{
		if (Std.is(a, Array))
		{
			var i:Int = a.length, j:Int, t:Dynamic;
			while (--i > 0)
			{
				t = a[i];
				a[i] = a[j = HXP.rand(i + 1)];
				a[j] = t;
			}
		}
	}

	public static var time(null, set_time):Float;
	private static inline function set_time(value:Float):Float {
		_time = value;
		return _time;
	}

	public static inline function gotoIsNull():Bool { return (_goto == null); }

	// World information.
	private static var _scene:Scene = new Scene();
	private static var _goto:Scene;

	// Console information.
	private static var _console:Console;

	// Time information.
	private static var _time:Float;
	public static var _updateTime:Float;
	public static var _renderTime:Float;
	public static var _gameTime:Float;
	public static var _systemTime:Float;

	// Bitmap storage.
#if haxe3
	private static var _bitmap:Map<String,BitmapData> = new Map<String,BitmapData>();
#else
	private static var _bitmap:Hash<BitmapData> = new Hash<BitmapData>();
#end

	// Pseudo-random number generation (the seed is set in Engine's contructor).
	private static var _seed:Int = 0;

	// Volume control.
	private static var _volume:Float = 1;
	private static var _pan:Float = 0;
	private static var _soundTransform:SoundTransform = new SoundTransform();

	// Used for rad-to-deg and deg-to-rad conversion.
	public static var DEG(get_DEG, never):Float;
	public static inline function get_DEG(): Float { return -180 / Math.PI; }
	public static var RAD(get_RAD, never):Float;
	public static inline function get_RAD(): Float { return Math.PI / -180; }

	// Global Flash objects.
	public static var stage:Stage;
	public static var engine:Engine;

	// Global objects used for rendering, collision, etc.
	public static var point:Point = new Point();
	public static var point2:Point = new Point();
	public static var zero:Point = new Point();
	public static var rect:Rectangle = new Rectangle();
	public static var matrix:Matrix = new Matrix();
	public static var sprite:Sprite = new Sprite();
	public static var entity:Entity;
}
