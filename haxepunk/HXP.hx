package haxepunk;

import haxe.Timer;
import haxepunk.Tween.TweenType;
import haxepunk.input.Mouse;
import haxepunk.math.MathUtil;
import haxepunk.math.Random;
import haxepunk.math.Rectangle;
import haxepunk.math.Vector2;
import haxepunk.tweens.misc.Alarm;
import haxepunk.tweens.misc.MultiVarTween;
import haxepunk.utils.HaxelibInfo;

/**
 * Static catch-all class used to access global properties and functions.
 */
class HXP
{
	/**
	 * The HaxePunk version.
	 * Format: Major.Minor.Patch
	 */
	public static inline var VERSION:String = HaxelibInfo.version;

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
	 * Game time elapsed since the last frame. For fixed framerate, this will be
	 * a constant 1/framerate.
	 */
	public static var elapsed:Float;

	/**
	 * Timescale applied to HXP.elapsed.
	 */
	public static var rate:Float = 1;

	/**
	 * The Screen object, use to transform or offset the Screen.
	 */
	public static var screen:Screen;

	/**
	 * A rectangle representing the size of the screen.
	 */
	public static var bounds:Rectangle;

	/**
	 * The default font file to use, by default: font/monofonto.ttf.
	 */
	public static var defaultFont:String = "font/monofonto";

	/**
	 * Point used to determine drawing offset in the render loop.
	 */
	public static var camera(get, never):Camera;
	static inline function get_camera() return scene == null ? null : scene.camera;

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
	 * Defines the allowed orientations
	 */
	public static var orientations:Array<Int> = [];

	public static var cursor(default, set):Cursor;
	static inline function set_cursor(cursor:Cursor = null):Cursor
	{
		if (HXP.cursor == cursor) return cursor;
		if (cursor == null) Mouse.showCursor();
		else Mouse.hideCursor();
		return HXP.cursor = cursor;
	}

	/**
	 * The choose function randomly chooses and returns one of the provided values.
	 */
	public static var choose(get, null):Dynamic;
	static function get_choose():Dynamic
	{
		return Reflect.makeVarArgs(_choose);
	}
	static inline function _choose(objs:Array<Dynamic>):Dynamic
	{
		if (objs == null || objs.length == 0)
		{
			throw "Can't choose a random element on an empty array";
		}

		if (Std.is(objs[0], Array)) // Passed an Array
		{
			var c:Array<Dynamic> = cast(objs[0], Array<Dynamic>);

			if (c.length != 0)
			{
				return c[Random.randInt(c.length)];
			}
			else
			{
				throw "Can't choose a random element on an empty array";
			}
		}
		else // Passed multiple args
		{
			return objs[Random.randInt(objs.length)];
		}
	}

	/**
	 * The currently active Scene object. When you set this, the Scene is flagged
	 * to switch, but won't actually do so until the end of the current frame.
	 */
	public static var scene(get, set):Scene;
	static inline function get_scene():Scene return engine.scene;
	static inline function set_scene(value:Scene):Scene return engine.scene = value;

	/**
	 * If we're currently rendering, this is the Scene being rendered now.
	 */
	public static var renderingScene:Scene;

	/**
	 * Resize the screen.
	 * @param width		New width.
	 * @param height	New height.
	 */
	public static function resize(width:Int, height:Int)
	{
		// resize scene to scale
		HXP.windowWidth = width;
		HXP.windowHeight = height;
		HXP.screen.resize(width, height);
		HXP.halfWidth = HXP.width / 2;
		HXP.halfHeight = HXP.height / 2;
		HXP.bounds.width = width;
		HXP.bounds.height = height;
		HXP.scene._resize();
	}

	/**
	 * Empties an array of its' contents
	 * @param array filled array
	 */
	public static inline function clear<T>(array:Array<T>)
	{
#if cpp
		// splice causes Array allocation, so prefer pop for most arrays
		if (array.length > 256) array.splice(0, array.length);
		else while (array.length > 0) array.pop();
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
	public static var fullscreen(get, set):Bool;
	static inline function get_fullscreen():Bool return HXP.app.fullscreen;
	static inline function set_fullscreen(value:Bool):Bool return HXP.app.fullscreen = value;

	/**
	 * Global volume factor for all sounds, a value from 0 to 1.
	 */
	public static var volume(default, set):Float = 1;
	static function set_volume(value:Float):Float
	{
		value = MathUtil.clamp(value, 0, 1);
		if (volume == value) return value;
		volume = value;
		Sfx.onGlobalUpdated(false);
		return volume;
	}

	/**
	 * Global panning factor for all sounds, a value from -1 to 1.
	 * Panning only applies to mono sounds. It is ignored on stereo.
	 */
	public static var pan(get, set):Float;
	static inline function get_pan():Float return _pan;
	static function set_pan(value:Float):Float
	{
		if (value < -1) value = -1;
		if (value > 1) value = 1;
		if (_pan == value) return value;
		_pan = value;
		Sfx.onGlobalUpdated(true);
		return _pan;
	}

	/**
	 * Optimized version of Lambda.indexOf for Array on dynamic platforms (Lambda.indexOf is less performant on those targets).
	 *
	 * @param	arr		The array to look into.
	 * @param	param	The value to look for.
	 * @return	Returns the index of the first element [v] within Array [arr].
	 * This function uses operator [==] to check for equality.
	 * If [v] does not exist in [arr], the result is -1.
	 **/
	public static inline function indexOf<T>(arr:Array<T>, v:T):Int
	{
		#if (haxe_ver >= 3.1)
		return arr.indexOf(v);
		#elseif js
		return untyped arr.indexOf(v);
		#else
		return std.Lambda.indexOf(arr, v);
		#end
	}

	/**
	 * Returns the next item after current in the list of options.
	 * @param	current		The currently selected item (must be one of the options).
	 * @param	options		An array of all the items to cycle through.
	 * @param	loop		If true, will jump to the first item after the last item is reached.
	 * @return	The next item in the list.
	 */
	public static inline function next<T>(current:T, options:Array<T>, loop:Bool = true):T
	{
		if (loop)
			return options[(indexOf(options, current) + 1) % options.length];
		else
			return options[Std.int(Math.min(indexOf(options, current) + 1, options.length - 1))];
	}

	/**
	 * Returns the item previous to the current in the list of options.
	 * @param	current		The currently selected item (must be one of the options).
	 * @param	options		An array of all the items to cycle through.
	 * @param	loop		If true, will jump to the last item after the first is reached.
	 * @return	The previous item in the list.
	 */
	public static inline function prev<T>(current:T, options:Array<T>, loop:Bool = true):T
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
	public static inline function swap<T>(current:T, a:T, b:T):T
	{
		return current == a ? b : a;
	}

	/**
	 * Binary insertion sort
	 * @param list     A list to insert into
	 * @param key      The key to insert
	 * @param compare  A comparison function to determine sort order
	 */
	public static function insertSortedKey<T>(list:Array<T>, key:T, compare:T->T->Int):Void
	{
		var result:Int = 0,
			mid:Int = 0,
			min:Int = 0,
			max:Int = list.length - 1;
		while (max >= min)
		{
			mid = min + Std.int((max - min) / 2);
			result = compare(list[mid], key);
			if (result > 0) max = mid - 1;
			else if (result < 0) min = mid + 1;
			else return;
		}

		list.insert(result > 0 ? mid : mid + 1, key);
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
	 * Example: HXP.tween(object, { x: 500, y: 350 }, 2.0, { ease: Float -> Float, complete: onComplete } );
	 */
	public static function tween(object:Dynamic, values:Dynamic, duration:Float, options:Dynamic = null):MultiVarTween
	{
		if (options != null && Reflect.hasField(options, "delay"))
		{
			var delay:Float = options.delay;
			Reflect.deleteField( options, "delay" );
			HXP.alarm(delay, function () HXP.tween(object, values, duration, options));
			return null;
		}

		var type:TweenType = TweenType.OneShot,
			complete:Void -> Void = null,
			ease:Float -> Float = null,
			tweener:Tweener = HXP.tweener;
		if (Std.is(object, Tweener)) tweener = cast(object, Tweener);
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
			if (Reflect.hasField(options, "tweener")) tweener = options.tweener;
		}
		var tween:MultiVarTween = new MultiVarTween(type);
		if (complete != null) tween.onComplete.bind(complete);
		tween.tween(object, values, duration, ease);
		tweener.addTween(tween, true);
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
	public static function alarm(delay:Float, complete:Void -> Void, ?type:TweenType, ?tweener:Tweener):Alarm
	{
		if (type == null) type = TweenType.OneShot;
		if (tweener == null) tweener = HXP.tweener;

		var alarm:Alarm = new Alarm(delay, type);
		if (complete != null) alarm.onComplete.bind(complete);
		tweener.addTween(alarm, true);
		return alarm;
	}

	/**
	 * Gets an array of frame indices.
	 * @param	from	Starting frame.
	 * @param	to		Ending frame.
	 * @param	skip	Skip amount every frame (eg. use 1 for every 2nd frame).
	 *
	 * @return	The array.
	 */
	public static function frames(from:Int, to:Int, skip:Int = 0):Array<Int>
	{
		var a:Array<Int> = new Array<Int>();
		skip++;
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
	public static function shuffle<T>(a:Array<T>)
	{
		var i:Int = a.length, j:Int, t:T;
		while (--i > 0)
		{
			t = a[i];
			a[i] = a[j = Random.randInt(i + 1)];
			a[j] = t;
		}
	}

	public static var time(null, set):Float;
	static inline function set_time(value:Float):Float
	{
		_time = value;
		return _time;
	}

	// Time information.
	static var _time:Float;
	@:dox(hide) public static var _updateTime:Float;
	@:dox(hide) public static var _gameTime:Float;
	@:dox(hide) public static var _systemTime:Float;

	// Volume control.
	static var _pan:Float = 0;

	/** The Engine instance. */
	public static var engine:Engine;

	public static var app:App;

	// Global objects used for rendering, collision, etc.
	@:dox(hide) public static var point:Vector2 = new Vector2();
	@:dox(hide) public static var point2:Vector2 = new Vector2();
	@:dox(hide) public static var zeroCamera:Camera = new Camera();
	@:dox(hide) public static var rect:Rectangle = new Rectangle();
	@:dox(hide) public static var entity:Entity;
}
