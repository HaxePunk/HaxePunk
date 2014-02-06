package com.haxepunk.graphics;

import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.HXP;
import com.haxepunk.graphics.atlas.TileAtlas;

import flash.display.BitmapData;
import flash.display.SpreadMethod;
import flash.geom.Point;
import flash.geom.Rectangle;

typedef CallbackFunction = Void -> Void;

/**
 * Performance-optimized animated Image. Can have multiple animations,
 * which draw frames from the provided source image to the screen.
 */
class Spritemap extends Image
{
	/**
	 * If the animation has stopped.
	 */
	public var complete:Bool;

	/**
	 * Optional callback function for animation end.
	 */
	public var callbackFunc:CallbackFunction;

	/**
	 * Animation speed factor, alter this to speed up/slow down all animations.
	 */
	public var rate:Float;

	/**
	 * Constructor.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 * @param	cbFunc			Optional callback function for animation end.
	 * @param	name			Optional name, necessary to identify the bitmapData if you are using flipped.
	 */
	public function new(source:Dynamic, frameWidth:Int = 0, frameHeight:Int = 0, cbFunc:CallbackFunction = null, name:String = "")
	{
		complete = true;
		rate = 1;
		_anims = new Map<String,Animation>();
		_timer = _frame = 0;

		_rect = new Rectangle(0, 0, frameWidth, frameHeight);
		if (Std.is(source, TileAtlas))
		{
			blit = false;
			_atlas = cast(source, TileAtlas);
			_region = _atlas.getRegion(_frame);
		}
		else if (HXP.renderMode == RenderMode.HARDWARE)
		{
			blit = false;
			_atlas = new TileAtlas(source, frameWidth, frameHeight);
			_region = _atlas.getRegion(_frame);
		}

		super(source, _rect, name);

		if (blit)
		{
			_width = _source.width;
			_height = _source.height;
		}
		else
		{
			_width = Std.int(_atlas.width);
			_height = Std.int(_atlas.height);
		}
		if (frameWidth == 0) _rect.width = _width;
		if (frameHeight == 0) _rect.height = _height;

		if (_width % _rect.width != 0 || _height % _rect.height != 0)
			throw "Source image width and height should be multiples of the frame width and height.";

		_columns = Math.ceil(_width / _rect.width);
		_rows = Math.ceil(_height / _rect.height);
		_frameCount = _columns * _rows;
		callbackFunc = cbFunc;

		updateBuffer();
		active = true;
	}

	/**
	 * Updates the spritemap's buffer.
	 */
	override public function updateBuffer(clearBefore:Bool = false)
	{
		if (blit)
		{
			// get position of the current frame
			if (_width > 0 && _height > 0) {
				_rect.x = _rect.width * _frame;
				_rect.y = Std.int(_rect.x / _width) * _rect.height;
				_rect.x = _rect.x % _width;
				if (_flipped) _rect.x = (_width - _rect.width) - _rect.x;
			}

			// update the buffer
			super.updateBuffer(clearBefore);
		}
		else
		{
			_region = _atlas.getRegion(_frame);
		}
	}

	/** @private Updates the animation. */
	override public function update()
	{
		if (_anim != null && !complete)
		{
			_timer += (HXP.fixed ? _anim.frameRate / HXP.assignedFrameRate : _anim.frameRate * HXP.elapsed) * rate;
			if (_timer >= 1)
			{
				while (_timer >= 1)
				{
					_timer --;
					_index ++;
					if (_index == _anim.frameCount)
					{
						if (_anim.loop)
						{
							_index = 0;
							if (callbackFunc != null) callbackFunc();
						}
						else
						{
							_index = _anim.frameCount - 1;
							complete = true;
							if (callbackFunc != null) callbackFunc();
							break;
						}
					}
				}
				if (_anim != null) _frame = Std.int(_anim.frames[_index]);
				updateBuffer();
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

		if(frameRate == 0)
			frameRate = HXP.assignedFrameRate;

		for (i in 0...frames.length)
		{
			frames[i] %= _frameCount;
			if (frames[i] < 0) frames[i] += _frameCount;
		}
		var anim = new Animation(name, frames, frameRate, loop);
		_anims.set(name, anim);
		anim.parent = this;
		return anim;
	}

	/**
	 * Plays an animation.
	 * @param	name		Name of the animation to play.
	 * @param	reset		If the animation should force-restart if it is already playing.
	 * @return	Anim object representing the played animation.
	 */
	public function play(name:String = "", reset:Bool = false):Animation
	{
		if (!reset && _anim != null && _anim.name == name) return _anim;
		if (_anims.exists(name))
		{
			_anim = _anims.get(name);
			_timer = _index = 0;
			_frame = _anim.frames[0];
			complete = false;
		}
		else
		{
			_anim = null;
			_frame = _index = 0;
			complete = true;
		}
		updateBuffer();
		return _anim;
	}

	/**
	 * Gets the frame index based on the column and row of the source image.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 * @return	Frame index.
	 */
	public inline function getFrame(column:Int = 0, row:Int = 0):Int
	{
		return (row % _rows) * _columns + (column % _columns);
	}

	/**
	 * Sets the current display frame based on the column and row of the source image.
	 * When you set the frame, any animations playing will be stopped to force the frame.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 */
	public function setFrame(column:Int = 0, row:Int = 0)
	{
		_anim = null;
		var frame:Int = getFrame(column, row);
		if (_frame == frame) return;
		_frame = frame;
		updateBuffer();
	}

	/**
	 * Assigns the Spritemap to a random frame.
	 */
	public function randFrame()
	{
		frame = HXP.rand(_frameCount);
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
	public var frame(get_frame, set_frame):Int;
	private function get_frame():Int { return _frame; }
	private function set_frame(value:Int):Int
	{
		_anim = null;
		value %= _frameCount;
		if (value < 0) value = _frameCount + value;
		if (_frame == value) return _frame;
		_frame = value;
		updateBuffer();
		return _frame;
	}

	/**
	 * Current index of the playing animation.
	 */
	public var index(get_index, set_index):Int;
	private function get_index():Int { return _anim != null ? _index : 0; }
	private function set_index(value:Int):Int
	{
		if (_anim == null) return 0;
		value %= _anim.frameCount;
		if (_index == value) return _index;
		_index = value;
		_frame = _anim.frames[_index];
		updateBuffer();
		return _index;
	}

	/**
	 * The amount of frames in the Spritemap.
	 */
	public var frameCount(get_frameCount, null):Int;
	private function get_frameCount():Int { return _frameCount; }

	/**
	 * Columns in the Spritemap.
	 */
	public var columns(get_columns, null):Int;
	private function get_columns():Int { return _columns; }

	/**
	 * Rows in the Spritemap.
	 */
	public var rows(get_rows, null):Int;
	private function get_rows():Int { return _rows; }

	/**
	 * The currently playing animation.
	 */
	public var currentAnim(get_currentAnim, null):String;
	private function get_currentAnim():String { return (_anim != null) ? _anim.name : ""; }

	// Spritemap information.
	private var _rect:Rectangle;
	private var _width:Int;
	private var _height:Int;
	private var _columns:Int;
	private var _rows:Int;
	private var _frameCount:Int;
	private var _anims:Map<String,Animation>;
	private var _anim:Animation;
	private var _index:Int;
	private var _frame:Int;
	private var _timer:Float;
	private var _atlas:TileAtlas;
	private var _regions:Array<AtlasRegion>;
}
