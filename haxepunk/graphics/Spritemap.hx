package haxepunk.graphics;

import flash.geom.Rectangle;
import haxe.ds.Either;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.utils.Random;

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
	public var endAnimation:Signal = new Signal();

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
	public var currentAnim(get, null):String;
	function get_currentAnim():String return (_anim != null) ? _anim.name : "";

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

		_atlas.prepare(frameWidth == 0 ? Std.int(_atlas.width) : frameWidth,
			frameHeight == 0 ? Std.int(_atlas.height) : frameHeight);

		frame = 0;
		active = true;
	}

	/** @private Updates the animation. */
	@:dox(hide)
	override public function update()
	{
		if (_anim != null && !complete)
		{
			_timer += _anim.frameRate * HXP.elapsed * rate;
			if (_timer >= 1)
			{
				while (_timer >= 1)
				{
					_timer--;
					_index += reverse ? -1 : 1;

					if ((reverse && _index == -1) || (!reverse && _index == _anim.frameCount))
					{
						if (_anim.loop)
						{
							_index = reverse ? _anim.frameCount - 1 : 0;
							endAnimation.invoke();
						}
						else
						{
							_index = reverse ? 0 : _anim.frameCount - 1;
							complete = true;
							endAnimation.invoke();
							break;
						}
					}
				}
				if (_anim != null) frame = Std.int(_anim.frames[_index]);
			}
		}
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
		if (_anims.get(name) != null)
			throw "Cannot have multiple animations with the same name";

		for (i in 0...frames.length)
		{
			frames[i] %= _atlas.tileCount;
			if (frames[i] < 0) frames[i] += _atlas.tileCount;
		}
		var anim = new Animation(name, frames, frameRate, loop);
		_anims.set(name, anim);
		anim.parent = this;
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
		if (!reset && _anim != null && _anim.name == name)
		{
			return _anim;
		}

		if (!_anims.exists(name))
		{
			stop(reset);
			return null;
		}

		_anim = _anims.get(name);
		this.reverse = reverse;
		restart();

		return _anim;
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

		if (!reset && _anim != null && _anim.frames == frames)
			return _anim;

		return playAnimation(new Animation(null, frames, frameRate, loop), reset, reverse);
	}

	/**
	 * Plays or restarts the supplied Animation.
	 * @param	animation	The Animation object to play
	 * @param	reset		When the supplied animation is currently playing, should it be force-restarted
	 * @param	reverse		If the animation should be played backward.
	 * @return	Anim object representing the played animation.
	 */
 	public function playAnimation(anim:Animation, reset:Bool = false, reverse:Bool = false): Animation
	{
		if (anim == null)
			throw "No animation supplied";

		if (!reset && _anim == anim)
			return anim;

		_anim = anim;
		this.reverse = reverse;
		restart();

		return anim;
	}

	/**
	 * Resets the animation to play from the beginning.
	 */
	public function restart()
	{
		_timer = _index = reverse ? _anim.frames.length - 1 : 0;
		frame = _anim.frames[_index];
		complete = false;
	}

	/**
	 * Immediately stops the currently playing animation.
	 * @param	reset		If true, resets the animation to the first frame.
	 */
	public function stop(reset:Bool = false)
	{
		if (reset)
			frame = _index = reverse ? _anim.frames.length - 1 : 0;

		_anim = null;
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
		var frames:Array<Int> = _anims.get(name).frames;
		index = index % frames.length;
		if (index < 0) index += frames.length;
		frame = frames[index];
	}

	/**
	 * Sets the current frame index.
	 */
	public var frame(default, set):Int;
	function set_frame(value:Int):Int
	{
		value %= _atlas.tileCount;
		if (value < 0) value = _atlas.tileCount + value;
		if (frame != value) {
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
	function get_index():Int return _anim != null ? _index : 0;
	function set_index(value:Int):Int
	{
		if (_anim == null) return 0;
		value %= _anim.frameCount;
		if (_index == value) return _index;
		_index = value;
		frame = _anim.frames[_index];
		return _index;
	}

	// Spritemap information.
	var _anims:Map<String, Animation>;
	var _anim:Animation;
	var _index:Int;
	var _timer:Float = 0;
	var _atlas:TileAtlas;
}
