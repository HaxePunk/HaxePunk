package haxepunk2d;

/**
 * Sound effect object used to play embedded sounds.
 */
class Sound // previously Sfx
{
	/** Global pan factor for all sounds, a value from -1 to 1. */
	public static var pan : Float;

	/** Global volume factor for all sounds, a value from 0 to 1. */
	public static var volume : Float;

	/**
	 * Return the global pan for a group.
	 */
	public static function getPan (group:String) : Float;

	/**
	 * Set the global pan for a single or multiple groups.
	 */
	public static function setPan (groups:Either<String,Array<String>>, pan:Float) : Float;

	/**
	 * Return the global volume for a group.
	 */
	public static function getVolume (group:String) : Float;

	/**
	 * Set the global volume for a single or multiple groups.
	 */
	public static function setVolume (groups:Either<String,Array<String>>, volume:Float) : Float;

	/**
	 * Creates a sound effect from an embedded source. Store a reference to this object so that you can play the sound using `play`.
	 */
	public function new (source:String, ?config:{onCompleted:Void->Void, onLoop:Void->Void, pan:Float, volume:Float, playing:Bool, position:Float, groups:Array<String>, loop:Bool});

	/** Length of the sound, in seconds. */
	public var length(default, null) : Float;

	/** If the sound is currently playing. */
	public var playing : Bool;

	/** Position of the currently playing sound, in seconds. */
	public var position : Float;

	/** Group(s) this sound belongs to. Can be used to mute or pan en masse.*/
	public var groups : Array<String>;

	/** Alter the volume factor (a value from 0 to 1) of the sound during playback. */
	public var volume : Float;

	/** Alter the panning factor (a value from -1 to 1) of the sound during playback. */
	public var pan : Float;

	/** Whether the sound will loop at the end or not. */
	public var loop : Bool;

	/** Function to call when the sound ends. Isn't called when looping. */
	public var onCompleted:Void->Void;

	/** Function to call when the sound loops. Isn't called when ending. */
	public var onLoop:Void->Void;

	/**
	 * Play the sound.
	 */
	public function play (restart:Bool = false, ?loop:Bool) : Void;

	/**
	 * Pause the sound.
	 */
	public function pause () : Void;
}
