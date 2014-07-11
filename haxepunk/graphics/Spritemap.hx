package haxepunk.graphics;

import haxepunk.math.Matrix4;
import haxepunk.math.Vector3;
import haxepunk.math.Math;
import haxepunk.renderers.Renderer;
import haxepunk.scene.Camera;
import haxe.ds.StringMap;
import lime.app.Event;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

/**
 * Template used by Spritemap to define animations. Don't create
 * these yourself, instead you can fetch them with Spritemap's add().
 */
class Animation
{

	/**
	 * Name of the animation.
	 */
	public var name(default, null):String;

	/**
	 * Array of frame indices to animate.
	 */
	public var frames(default, null):Array<Int>;

	/**
	 * Animation speed.
	 */
	public var frameRate(default, null):Float;

	/**
	 * Amount of frames in the animation.
	 */
	public var frameCount(default, null):Int;

	/**
	 * If the animation loops.
	 */
	public var loop:Bool;

	/**
	 * Constructor.
	 * @param	name		Animation name.
	 * @param	frames		Array of frame indices to animate.
	 * @param	frameRate	Animation speed.
	 * @param	loop		If the animation should loop.
	 */
	public function new(name:String, frames:Array<Int>, frameRate:Float = 0, loop:Bool = true)
	{
        this.name       = name;
        this.frames     = frames;
        this.frameRate  = (frameRate == 0 ? 12 : frameRate);
        this.loop       = loop;
        this.frameCount = frames.length;
	}

}

class Spritemap extends Image
{

	/**
	 * If the animation has stopped.
	 */
	public var complete:Bool = true;

	/**
	 * If the animation is played in reverse.
	 */
	public var reverse:Bool = false;

	/**
	 * Columns in the Spritemap.
	 */
	public var columns(default, null):Int = 0;
	/**
	 * Rows in the Spritemap.
	 */
	public var rows(default, null):Int = 0;

	/**
	 * The maximum amount of frames in the Spritemap.
	 */
	public var frameCount(default, null):Int = 0;

	/**
	 * Animation speed factor, alter this to speed up/slow down all animations.
	 */
	public var rate:Float = 1;

	/**
	 * Optional update function for animation end.
	 */
	public var onAnimEnd:Event<Void->Void>;

	/**
	 * The currently playing animation name.
	 */
	public var currentAnimName(get, set):String;
	private inline function get_currentAnimName():String { return (_anim == null ? "" : _anim.name); }
	private inline function set_currentAnimName(value:String):String { return play(value).name; }

	// override width/height for sprite size
	override private function get_width():Float { return _spriteWidth; }
	override private function get_height():Float { return _spriteHeight; }

	public function new(path:String, width:Int, height:Int)
	{
		_spriteWidth = width;
		_spriteHeight = height;
		_anims = new StringMap<Animation>();
		onAnimEnd = new Event<Void->Void>();

		super(path);
	}

	/**
	 * Add an Animation.
	 * @param	name		Name of the animation.
	 * @param	frames		Array of frame indices to animate through.
	 * @param	frameRate	Animation speed (in frames per second, 0 defaults to assigned frame rate)
	 * @param	loop		If the animation should loop
	 * @return	A new Anim object for the animation.
	 */
	public function add(name:String, frames:Array<Int>, frameRate:Float=0, loop:Bool=true):Void
	{
		if (_anims.get(name) != null)
			throw "Cannot have multiple animations with the same name";

		for (i in 0...frames.length)
		{
			frames[i] %= frameCount;
			if (frames[i] < 0) frames[i] += frameCount;
		}
		var anim = new Animation(name, frames, frameRate, loop);
		_anims.set(name, anim);
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

		if (reset == false && _anim != null && _anim.frames == frames)
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
 	public function playAnimation(anim:Animation, reset:Bool = false, reverse:Bool = false):Animation
	{
		if (anim == null)
			throw "No animation supplied";

		if (reset == false && _anim == anim)
			return anim;

		_anim = anim;
		this.reverse = reverse;
		restart();

		return anim;
	}

	/**
	 * Resets the animation to play from the beginning.
	 */
	public function restart():Void
	{
		_time = _index = reverse ? _anim.frames.length - 1 : 0;
		_frame = _anim.frames[_index];
		complete = false;
	}

	/**
	 * Immediately stops the currently playing animation.
	 * @param	reset		If true, resets the animation to the first frame.
	 */
	public function stop(reset:Bool = false):Void
	{
		_anim = null;

		if (reset)
			_frame = _index = reverse ? _anim.frames.length - 1 : 0;

		complete = true;
	}

	/**
	 * Gets the frame index based on the column and row of the source image.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 * @return	Frame index.
	 */
	public inline function getFrame(column:Int = 0, row:Int = 0):Int
	{
		return (row % rows) * columns + (column % columns);
	}

	/**
	 * Sets the current display frame based on the column and row of the source image.
	 * When you set the frame, any animations playing will be stopped to force the frame.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 */
	public function setFrame(column:Int = 0, row:Int = 0):Int
	{
		_anim = null;
		return _frame = getFrame(column, row);
	}

	/**
	 * Assigns the Spritemap to a random frame.
	 */
	public function randFrame()
	{
		frame = Math.rand(frameCount);
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
	 * Sets the current frame index. When you set this, any
	 * animations playing will be stopped to force the frame.
	 */
	public var frame(get, set):Int;
	private inline function get_frame():Int { return _frame; }
	private function set_frame(value:Int):Int
	{
		_anim = null;
		value %= frameCount;
		if (value < 0) value = frameCount + value;
		return _frame = value;
	}

	/**
	 * Current index of the playing animation.
	 */
	public var index(get, set):Int;
	private function get_index():Int { return _anim != null ? _index : 0; }
	private function set_index(value:Int):Int
	{
		if (_anim == null) return 0;
		value %= _anim.frameCount;
		if (_index != value)
		{
			_index = value;
			_frame = _anim.frames[_index];
		}
		return _index;
	}

	/** @private Updates the animation. */
	override public function update(elapsed:Float):Void
	{
		if (_anim != null && !complete)
		{
			// _time += (HXP.fixed ? _anim.frameRate / HXP.assignedFrameRate : _anim.frameRate * HXP.elapsed) * rate;
			_time += (_anim.frameRate * elapsed) * rate;
			if (_time >= 1)
			{
				do {
					_index += reverse ? -1 : 1;

					if ((reverse && _index == -1) || (!reverse && _index == _anim.frameCount))
					{
						if (_anim.loop)
						{
							_index = reverse ? _anim.frameCount - 1 : 0;
							onAnimEnd.dispatch();
						}
						else
						{
							_index = reverse ? 0 : _anim.frameCount - 1;
							complete = true;
							onAnimEnd.dispatch();
							break;
						}
					}
				} while (--_time >= 1);
				_frame = _anim.frames[_index];
			}
		}
	}

	override private function createBuffer():Void
	{
		columns = Math.ceil(_texture.originalWidth / _spriteWidth);
		rows = Math.ceil(_texture.originalHeight / _spriteHeight);
		frameCount = columns * rows;

		var data = new Array<Float>();
		data[frameCount*20-1] = 0; // quick resize

		var xx = (_spriteWidth / _texture.originalWidth) * (_texture.originalWidth / _texture.width);
		var yy = (_spriteHeight / _texture.originalHeight) * (_texture.originalHeight / _texture.height);
		var i = 0;
		for (y in 0...rows)
		{
			for (x in 0...columns)
			{
				data[i++] = data[i++] = data[i++] = 0; // vert (0, 0, 0)
				data[i++] = x * xx; // tex
				data[i++] = y * yy;

				data[i++] = 0; data[i++] = 1; data[i++] = 0; // vert (0, 1, 0)
				data[i++] = x * xx; // tex
				data[i++] = (y + 1) * yy;

				data[i++] = 1; data[i++] = data[i++] = 0; // vert (1, 0, 0)
				data[i++] = (x + 1) * xx; // tex
				data[i++] = y * yy;

				data[i++] = data[i++] = 1; data[i++] = 0; // vert (1, 1, 0)
				data[i++] = (x + 1) * xx; // tex
				data[i++] = (y + 1) * yy;
			}
		}
		_vertexBuffer = Renderer.updateBuffer(new Float32Array(data), 5);

		var indices = new Array<Int>();
		for (frame in 0...frameCount)
		{
			indices.push(frame * 4 + 0);
			indices.push(frame * 4 + 1);
			indices.push(frame * 4 + 2);
			indices.push(frame * 4 + 1);
			indices.push(frame * 4 + 2);
			indices.push(frame * 4 + 3);
		}
		_indexBuffer = Renderer.updateIndexBuffer(new Int16Array(indices));
	}

	override public function draw(camera:Camera, offset:Vector3):Void
	{
		drawBuffer(camera, offset, _frame);
	}

	private var _frame:Int = 0;
	private var _index:Int = 0;
	private var _spriteWidth:Float = 0;
	private var _spriteHeight:Float = 0;
	private var _time:Float = 0;
	private var _anim:Animation;
	private var _anims:StringMap<Animation>;

}
