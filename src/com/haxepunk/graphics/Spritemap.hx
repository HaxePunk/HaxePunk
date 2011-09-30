package com.haxepunk.graphics;

import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.SpreadMethod;
import nme.geom.Point;
import nme.geom.Rectangle;
import com.haxepunk.HXP;

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
	 * @param	callback		Optional callback function for animation end.
	 */
	public function new(source:Dynamic, frameWidth:Int = 0, frameHeight:Int = 0, cbFunc:CallbackFunction = null, name:String = "BitmapData") 
	{
		complete = true;
		rate = 1;
		_anims = new Hash<Animation>();
		_timer = 0;
		
		_rect = new Rectangle(0, 0, frameWidth, frameHeight);
		super(source, _rect, name);
		if (frameWidth == 0) _rect.width = this.source.width;
		if (frameHeight == 0) _rect.height = this.source.height;
		
		_width = this.source.width;
		_height = this.source.height;
		_columns = Std.int(_width / _rect.width);
		_rows = Std.int(_height / _rect.height);
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
		// get position of the current frame
		_rect.x = _rect.width * _frame;
		_rect.y = Std.int(_rect.x / _width) * _rect.height;
		_rect.x = _rect.x % _width;
		
		if (_flipped) _rect.x = (_width - _rect.width) - _rect.x;
		
		// update the buffer
		super.updateBuffer(clearBefore);
	}
	
	/** @private Updates the animation. */
	override public function update() 
	{
		if (_anim != null && !complete)
		{
			_timer += (HXP.fixed ? _anim.frameRate : _anim.frameRate * HXP.elapsed) * rate;
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
	 * @param	frameRate	Animation speed.
	 * @param	loop		If the animation should loop.
	 * @return	A new Anim object for the animation.
	 */
	public function add(name:String, frames:Array<Int>, frameRate:Float = 0, loop:Bool = true):Animation
	{
		if (_anims.get(name) != null) throw "Cannot have multiple animations with the same name";
		var anim:Animation = new Animation(name, frames, frameRate, loop);
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
		_anim = _anims.get(name);
		if (_anim == null)
		{
			_frame = _index = 0;
			complete = true;
			updateBuffer();
			return null;
		}
		_index = 0;
		_timer = 0;
		_frame = _anim.frames[0];
		complete = false;
		updateBuffer();
		return _anim;
	}
	
	/**
	 * Gets the frame index based on the column and row of the source image.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 * @return	Frame index.
	 */
	public function getFrame(column:Int = 0, row:Int = 0):Int
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
		var frame:Int = (row % _rows) * _columns + (column % _columns);
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
	public var frame(getFrameIndex, setFrameIndex):Int;
	private function getFrameIndex():Int { return _frame; }
	private function setFrameIndex(value:Int):Int
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
	public var index(getIndex, setIndex):Int;
	private function getIndex():Int { return _anim != null ? _index : 0; }
	private function setIndex(value:Int):Int
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
	public var frameCount(getFrameCount, null):Int;
	private function getFrameCount():Int { return _frameCount; }
	
	/**
	 * Columns in the Spritemap.
	 */
	public var columns(getColumns, null):Int;
	private function getColumns():Int { return _columns; }
	
	/**
	 * Rows in the Spritemap.
	 */
	public var rows(getRows, null):Int;
	private function getRows():Int { return _rows; }
	
	/**
	 * The currently playing animation.
	 */
	public var currentAnim(getCurrentAnim, null):String;
	private function getCurrentAnim():String { return (_anim != null) ? _anim.name : ""; }
	
	// Spritemap information.
	private var _rect:Rectangle;
	private var _width:Int;
	private var _height:Int;
	private var _columns:Int;
	private var _rows:Int;
	private var _frameCount:Int;
	private var _anims:Hash<Animation>;
	private var _anim:Animation;
	private var _index:Int;
	private var _frame:Int;
	private var _timer:Float;
}