package haxepunk2d.graphics;

typedef AnimationConfig = {
	> GraphicConfig,
	onCompleted:Sequence->Void,
	onLoop:Sequence->Void
};

/**
 * Performance-optimized animated Image.
 * Can have multiple animations, which draw frames
 * from the provided source image to the screen.
 */
class Animation extends Graphics
{
	/** The number of columns the animation has. */
	public var columns:Int;

	/** The number of rows the animation has. */
	public var rows:Int;

	/** If a sequence is currently running. */
	public var playing : Bool;

	/** Function to call when a sequence ends. Isn't called when looping. */
	public var onCompleted:Sequence->Void;

	/** Function to call when a sequence loops. Isn't called when ending. */
	public var onLoop:Sequence->Void;

	/** The sequence currently running, null if no sequence is running. */
	public var sequence : Sequence;

	/** Animation speed factor, alter this to speed up/slow down all sequences. */
	public var speedFactor : Float;

	/**
	 * Create a new animation.
	 */
	public function new(source:String, frameWidth:Int, frameHeight:Int, ?config:AnimationConfig);

	/**
	 * Register a sequence, if a sequence already exists with
	 * this name it will overwrite the old one.
	 */
	public function add(name:String, frames:Either<Array<Int>, Array<Point>>, frameRate:Float, ?config:SequenceConfig);

	/**
	 * Play the sequence.
	 * If a name is provided but no such sequence exists
	 * then the currently running sequence is stoped.
	 */
	public function play(e:Either<String, Sequence>, ?config:{ reset:Bool, reverse:Bool });

	/**
	 * Pause the currently running sequence.
	 * If no sequence is running do nothing.
	 */
	public function pause():Void;

	/**
	 * Resume the currently running sequence.
	 * If no sequence is running do nothing.
	 */
	public function resume():Void;

	/**
	 * Restart the sequence, the onCompleted
	 * or onLooped functions aren't called.
	 * If no sequence is running do nothing.
	 */
	public function restart():Void;

	/**
	 * Stop the sequence, the onCompleted
	 * function isn't called.
	 * If no sequence is running do nothing.
	 */
	public function stop():Void;

	/**
	 * Returns a sequence by it's name.
	 * If no sequence has this name returns null.
	 * If two sequences have this name returns the first one found.
	 */
	public function get(name:String):Sequence;

	/**
	 * Returns all sequences.
	 */
	public function getAll():Array<Sequence>;

	/**
	 * Returns all the sequences' name.
	 */
	public function getAllName():Array<String>;

	/**
	 * Returns whether a sequence with the name [name] exists.
	 */
	public function exists(name:String):Bool;

	/**
	 * Unregister a sequence from this animation.
	 * If a name is provided but no such sequence
	 * exists then do nothing.
	 */
	public function remove(e:Either<String, Sequence>):Void;

	/**
	 * Sets the current displayed frame from either
	 * it's index or it's Point(column, row).
	 * If a sequence was running stops it without calling
	 * the onCompleted function.
	 */
	public function setFrame(e:Either<Int, Point>):Void;

	/**
	 * Set the animation to a random frame,
	 * you can specify a max index in case your source
	 * isn't fully used (there is blank space at the end).
	 * If a sequence was running stops it without calling
	 * the onCompleted function.
	 */
	public function randFrame(?maxIndex:Int):Void;
}

typedef SequenceConfig = {
	reverse:Bool,
	loop:Bool,
	onCompleted:Sequence->Void,
	onLoop:Sequence->Void
};

class Sequence
{
	/** The sequence's name. */
	public var name:String;

	/** If the sequence has stopped. */
	public var complete:Bool;

	/** The number of frame in the sequence. */
	public var length:Int;

	/** The current frame playing. Changing this value does not stop the sequence. */
	public var position:Int;

	/** The frame rate of the sequence. */
	public var frameRate:Float;

	/** If the sequence is playing in reverse. */
	public var reverse:Bool;

	/** If the sequence is currently playing. */
	public var playing : Bool;

	/** The array of frame indices the sequence is playing. */
	public var frames : Array<Int>;

	/** Whether the sequence loops. */
	public var loop : Bool;

	/** The parent Animation this sequence was defined in. */
	public var parent : Animation.

	/** Function to call when the sequence ends instead of the one in the animation. Isn't called when looping. */
	public var onCompleted:Sequence->Void;

	/** Function to call when a sequence loops instead of the one in the animation. Isn't called when ending. */
	public var onLoop:Sequence->Void;

	/**
	 * Play this sequence in the parent animation.
	 * Omitted configurations values will use the following defaults:
	 * { reset: false, reverse: false }.
	 */
	public function play(?config:{ reset:Bool, reverse:Bool });

	/**
	 * Pause the sequence.
	 */
	public function pause():Void;

	/**
	 * Resume the sequence.
	 */
	public function resume():Void;

	/**
	 * Restart the sequence, the onCompleted
	 * or onLooped functions aren't called.
	 */
	public function restart():Void;

	/**
	 * Stop the sequence, the onCompleted
	 * function isn't called.
	 */
	public function stop():Void;
}
