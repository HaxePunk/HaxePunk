package haxepunk.graphics;

/**
 * Template used by `Spritemap` to define animations. Don't create
 * these yourself, instead you can fetch them with `Spritemap.add`.
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
        this.frameRate  = (frameRate == 0 ? HXP.assignedFrameRate : frameRate);
        this.loop       = loop;
        this.frameCount = frames.length;
        this.parent 	= parent;
	}

	/**
	 * Plays the animation.
	 * @param	reset		If the animation should force-restart if it is already playing.
	 */
	public function play(reset:Bool = false, reverse:Bool = false)
	{
		if (name == null)
			_parent.playAnimation(this, reset, reverse);
		else
			_parent.play(name, reset, reverse);
	}

	@:dox(hide)
	public var parent(null, set):Spritemap;
	function set_parent(value:Spritemap):Spritemap return _parent = value;

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

	var _parent:Spritemap;
}
