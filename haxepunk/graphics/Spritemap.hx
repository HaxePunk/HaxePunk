package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLBuffer;
import lime.utils.Float32Array;
import haxepunk.math.Matrix3D;
import lime.utils.Vector3D;
import haxe.Timer;
import haxe.ds.StringMap;

/**
 * Template used by Spritemap to define animations. Don't create
 * these yourself, instead you can fetch them with Spritemap's add().
 */
class Animation
{

	/**
	 * Constructor.
	 * @param	name		Animation name.
	 * @param	frames		Array of frame indices to animate.
	 * @param	frameRate	Animation speed.
	 * @param	loop		If the animation should loop.
	 */
	public function new(name:String, frames:Array<Int>, frameRate:Float = 0, loop:Bool = true, parent:Spritemap = null)
	{
        this.name       = name;
        this.frames     = frames;
        this.frameRate  = (frameRate == 0 ? 12 : frameRate);
        this.loop       = loop;
        this.frameCount = frames.length;
        this.parent 	= parent;
	}

	/**
	 * Plays the animation.
	 * @param	reset		If the animation should force-restart if it is already playing.
	 */
	public function play(reset:Bool = false, reverse:Bool = false):Void
	{
		// if(name == null)
		// 	_parent.playAnimation(this, reset, reverse);
		// else
		// 	_parent.play(name, reset, reverse);
	}

	public var parent(null, set):Spritemap;
	private function set_parent(value:Spritemap):Spritemap {
		_parent = value;
		return _parent;
	}

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
	public var loop(default, null):Bool;

	private var _parent:Spritemap;
}

class Spritemap extends Image
{

	/**
	 * If the animation is played in reverse.
	 */
	public var reverse:Bool;

	public var columns(default, null):Int;
	public var rows(default, null):Int;

	// override width/height for sprite size
	override private function get_width():Float { return _spriteWidth; }
	override private function get_height():Float { return _spriteHeight; }

	public function new(path:String, width:Int, height:Int)
	{
		super(path);
		_spriteWidth = width;
		_spriteHeight = height;
		_time = Timer.stamp();
		_anims = new StringMap<Animation>();
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
		_texture.onload = function() {
			if (_anims.get(name) != null)
				throw "Cannot have multiple animations with the same name";

			for (i in 0...frames.length)
			{
				frames[i] %= _frameCount;
				if (frames[i] < 0) frames[i] += _frameCount;
			}
			var anim = new Animation(name, frames, frameRate, loop);
			_anims.set(name, anim);
			anim.parent = this;
		}
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
	 * Resets the animation to play from the beginning.
	 */
	public function restart()
	{
		_time = _index = reverse ? _anim.frames.length - 1 : 0;
		_frame = _anim.frames[_index];
	}

	/**
	 * Immediately stops the currently playing animation.
	 * @param	reset		If true, resets the animation to the first frame.
	 */
	public function stop(reset:Bool = false)
	{
		_anim = null;

		if (reset)
			_frame = _index = reverse ? _anim.frames.length - 1 : 0;
	}

	override private function initBuffer():Void
	{
		_texture.onload = function() {
			columns = Math.ceil(_texture.originalWidth / _spriteWidth);
			rows = Math.ceil(_texture.originalHeight / _spriteHeight);
			_frameCount = columns * rows;

			var data = new Array<Float>();
			data[_frameCount*32] = 0;

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
					data[i++] = data[i++] = 0; data[i++] = -1; // normal (0, 0, -1)

					data[i++] = 0; data[i++] = 1; data[i++] = 0; // vert (0, 1, 0)
					data[i++] = x * xx; // tex
					data[i++] = (y + 1) * yy;
					data[i++] = data[i++] = 0; data[i++] = -1; // normal (0, 0, -1)

					data[i++] = 1; data[i++] = data[i++] = 0; // vert (1, 0, 0)
					data[i++] = (x + 1) * xx; // tex
					data[i++] = y * yy;
					data[i++] = data[i++] = 0; data[i++] = -1; // normal (0, 0, -1)

					data[i++] = data[i++] = 1; data[i++] = 0; // vert (1, 1, 0)
					data[i++] = (x + 1) * xx; // tex
					data[i++] = (y + 1) * yy;
					data[i++] = data[i++] = 0; data[i++] = -1; // normal (0, 0, -1)
				}
			}
			_buffer = GL.createBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, _buffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast data), GL.STATIC_DRAW);
		}
	}

	override public function draw(projectionMatrix:lime.utils.Float32Array, modelViewMatrix:Matrix3D):Void
	{
		drawBuffer(projectionMatrix, modelViewMatrix, _buffer, _frame * 4);

		var now = Timer.stamp();
		if (now - _time > 0.1)
		{
			_frame += 1;
			if (_frame >= _frameCount) _frame = 0;
			_time = now;
		}
	}

	private var _buffer:GLBuffer;
	private var _frame:Int = 0;
	private var _spriteWidth:Float = 0;
	private var _spriteHeight:Float = 0;
	private var _time:Float = 0;
	private var _frameCount:Int = 0;
	private var _index:Int = 0;
	private var _anim:Animation;
	private var _anims:StringMap<Animation>;

}
