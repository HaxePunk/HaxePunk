package haxepunk.graphics;

import flash.geom.Rectangle;
import haxe.ds.Either;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.Signal;
import haxepunk.ds.Maybe;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.math.Random;

@:allow(haxepunk.graphics.Spritemap)
class Animation
{
	public var end:Signal0 = new Signal0();

	var frames:Array<Int>;
	var frameRate:Float;
	var frameCount:Int;
	var loop:Bool;
	var parent:Spritemap;

	function new(parent:Spritemap, frames:Array<Int>, frameRate:Float, loop:Bool)
	{
		this.frames = frames;
		this.frameRate = (frameRate == 0 ? HXP.assignedFrameRate : frameRate);
		this.frameCount = this.frames.length;
		this.loop = loop;
	}

	public function play(reset:Bool = false, reverse:Bool = false)
	{
		parent.playAnimation(this, reset, reverse);
	}

	public inline function getFirstFrame(reverse:Bool):Int
	{
		return reverse ? 0 : this.frameCount - 1;
	}

	public inline function getLastFrame(reverse:Bool):Int
	{
		return reverse ? this.frameCount - 1 : 0;
	}
}

/**
 * Performance-optimized animated Image. Can have multiple animations,
 * which draw frames from the provided source image to the screen.
 */
class Spritemap extends Image
{
	/**
	 * If the animation has stopped.
	 */
	public var complete:Bool = true;

	/**
	 * Callback function for animation end.
	 */
	public var endAnimation:Signal1<Animation> = new Signal1();

	/**
	 * Animation speed factor, alter this to speed up/slow down all animations.
	 */
	public var rate:Float = 1;

	/**
	 * If the animation is played in reverse.
	 */
	public var reverse:Bool = false;

	/**
	 * The currently playing animation.
	 */
	public var currentAnimation(default, null):Maybe<Animation>;

	/**
	 * Constructor.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function new(source:TileType, frameWidth:Int = 0, frameHeight:Int = 0)
	{
		_anims = new Map<String, Animation>();

		super();

		_atlas = source;

		if (frameWidth > _atlas.width || frameHeight > _atlas.height)
		{
			throw "Frame width and height can't be bigger than the source image dimension.";
		}

		_atlas.prepare(
			frameWidth == 0 ? Std.int(_atlas.width) : frameWidth,
			frameHeight == 0 ? Std.int(_atlas.height) : frameHeight
		);

		frame = 0;
		active = true;
	}

	/** @private Updates the animation. */
	@:dox(hide)
	override public function update()
	{
		currentAnimation.may(function(anim) {
			if (complete) return;

			_timer += HXP.elapsed * anim.frameRate * rate;
			if (_timer < 1) return;

			while (_timer >= 1)
			{
				_timer--;
				_index += reverse ? -1 : 1;

				if (_index < 0 || _index >= anim.frameCount)
				{
					if (anim.loop)
					{
						_index = anim.getLastFrame(reverse);
						anim.end.invoke();
						endAnimation.invoke(anim);
					}
					else
					{
						_index = anim.getFirstFrame(reverse);
						anim.end.invoke();
						complete = true;
						endAnimation.invoke(anim);
						break;
					}
				}
			}
			frame = Std.int(anim.frames[_index]);
		});
	}

	/**
	 * Add an Animation.
	 * @param	name		Name of the animation.
	 * @param	frames		Array of frame indices to animate through.
	 * @param	frameRate	Animation speed (in frames per second, 0 defaults to assigned frame rate)
	 * @param	loop		If the animation should loop
	 * @return	A new Anim object for the animation.
	 */
	public function add(name:String, frames:Array<Int>, frameRate:Float = 0, loop:Bool = true):Animation
	{
		if (_anims.exists(name))
		{
			throw "Cannot have multiple animations with the same name";
		}

		// make sure frames are valid
		var anim = new Animation(this, frames, frameRate, loop);
		_anims.set(name, anim);
		return anim;
	}

	/**
	 * Plays an animation previous defined by add().
	 * @param	name		Name of the animation to play.
	 * @param	reset		If the animation should force-restart if it is already playing.
	 * @param	reverse		If the animation should be played backward.
	 * @return	Anim object representing the played animation.
	 */
	public function play(name:String = "", reset:Bool = false, reverse:Bool = false):Animation
	{
		if (!_anims.exists(name))
		{
			stop(reset);
			return null;
		}

		return playAnimation(_anims.get(name), reset, reverse);
	}

	/**
	 * Plays a new ad hoc animation.
	 * @param	frames		Array of frame indices to animate through.
	 * @param	frameRate	Animation speed (in frames per second, 0 defaults to assigned frame rate)
	 * @param	loop		If the animation should loop
	 * @param	reset		When the supplied frames are currently playing, should the animation be force-restarted
	 * @param	reverse		If the animation should be played backward.
	 * @return	Anim object representing the played animation.
	 */
	public function playFrames(frames:Array<Int>, frameRate:Float = 0, loop:Bool = true, reset:Bool = false, reverse:Bool = false):Animation
	{
		if (frames == null || frames.length == 0)
		{
			stop(reset);
			return null;
		}

		return playAnimation(new Animation(this, frames, frameRate, loop), reset, reverse);
	}

	/**
	 * Plays or restarts the supplied Animation.
	 * @param	animation	The Animation object to play
	 * @param	reset		When the supplied animation is currently playing, should it be force-restarted
	 * @param	reverse		If the animation should be played backward.
	 * @return	Animation object representing the played animation.
	 */
	public function playAnimation(anim:Animation, reset:Bool = false, reverse:Bool = false): Animation
	{
		reset = reset || (currentAnimation != anim);
		currentAnimation = anim;
		this.reverse = reverse;
		if (reset) restart();

		return anim;
	}

	/**
	 * Resets the animation to play from the beginning.
	 */
	public function restart()
	{
		_timer = 0;
		currentAnimation.may(function(anim) {
			_index = anim.getLastFrame(reverse);
			frame = anim.frames[_index];
		});
		complete = false;
	}

	/**
	 * Immediately stops the currently playing animation.
	 * @param	reset		If true, resets the animation to the first frame.
	 */
	public function stop(reset:Bool = false)
	{
		if (reset)
		{
			frame = _index = currentAnimation.map(function(a) return a.getLastFrame(reverse), 0);
		}

		currentAnimation = null;
		complete = true;
	}

	/**
	 * Assigns the Spritemap to a random frame.
	 */
	public function randFrame()
	{
		frame = Random.randInt(_atlas.tileCount);
	}

	/**
	 * Sets the frame to the frame index of an animation.
	 * @param	name	Animation to draw the frame frame.
	 * @param	index	Index of the frame of the animation to set to.
	 */
	public function setAnimFrame(name:String, index:Int)
	{
		if (_anims.exists(name))
		{
			var anim = _anims.get(name);
			index = Std.int(Math.abs(index)) % anim.frameCount;
			frame = anim.frames[index];
		}
	}

	/**
	 * Sets the current frame index.
	 */
	public var frame(default, set):Int = -1;
	function set_frame(value:Int):Int
	{
		value = Std.int(Math.abs(value)) % _atlas.tileCount;
		if (frame != value)
		{
			_region = _atlas.getRegion(value);
			_sourceRect.width = _region.width;
			_sourceRect.height = _region.height;
		}
		return frame = value;
	}

	/**
	 * Current index of the playing animation.
	 */
	public var index(get, set):Int;
	function get_index():Int return currentAnimation.exists() ? _index : 0;
	function set_index(value:Int):Int
	{
		return currentAnimation.map(function(anim) {
			value %= anim.frameCount;
			if (_index == value) return _index;
			frame = anim.frames[value];
			return _index = value;
		}, 0);
	}

	// Spritemap information.
	var _anims:Map<String, Animation>;
	var _index:Int;
	var _timer:Float = 0;
	var _atlas:TileAtlas;
}
