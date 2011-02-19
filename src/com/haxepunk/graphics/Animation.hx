package com.haxepunk.graphics;

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
	public function new(name:String, frames:Array<Int>, frameRate:Float = 0, loop:Bool = true) 
	{
		_name = name;
		_frames = frames;
		_frameRate = frameRate;
		_loop = loop;
		_frameCount = frames.length;
	}
	
	/**
	 * Plays the animation.
	 * @param	reset		If the animation should force-restart if it is already playing.
	 */
	public function play(reset:Bool = false)
	{
		_parent.play(_name, reset);
	}
	
	public var parent(null, setParent):Spritemap;
	private function setParent(value:Spritemap):Spritemap {
		_parent = value;
		return _parent;
	}
	
	/**
	 * Name of the animation.
	 */
	public var name(getName, null):String;
	private function getName():String { return _name; }
	
	/**
	 * Array of frame indices to animate.
	 */
	public var frames(getFrames, null):Array<Int>;
	private function getFrames():Array<Int> { return _frames; }
	
	/**
	 * Animation speed.
	 */
	public var frameRate(getFrameRate, null):Float;
	private function getFrameRate():Float { return _frameRate; }
	
	/**
	 * Amount of frames in the animation.
	 */
	public var frameCount(getFrameCount, null):Int;
	private function getFrameCount():Int { return _frameCount; }
	
	/**
	 * If the animation loops.
	 */
	public var loop(getLoop, null):Bool;
	private function getLoop():Bool { return _loop; }
	
	private var _parent:Spritemap;
	private var _name:String;
	private var _frames:Array<Int>;
	private var _frameRate:Float;
	private var _frameCount:Int;
	private var _loop:Bool;
}