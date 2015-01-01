package haxepunk2d;

/**
 * Tweening object created when using Value.tweenTo functions.
 */
class Tween
{
	/** If the tween should update. */
	public var active:Bool;

	/** Progression of the tween, between 0 and 1. */
	public var percent(default, null):Float;

	/** If the tween should loop. */
	public var loop:Bool;

	/** Function to call when the tween ends. Isn't called when looping. */
	public var onCompleted:Void->Void;

	/** Function to call when the tween loops. Isn't called when ending. */
	public var onLoop:Void->Void;

	/** Delay, in seconds, before the tween start. */
	public var startDelay : Float;

	/** Delay, in seconds, before the tween loop. */
	public var loopDelay : Float;

	/**
	 * Restart the tween.
	 */
	public function restart(?loop:Bool):Void;

	/**
	 * Pause updating the tween.
	 */
	public function pause():Void;

	/**
	 * Resume updating the tween.
	 */
	public function resume():Void;

	/**
	 * Cancel immediatly the tween. The onComplete function isn't called.
	 * If [resetValue] the variable will return to its original value.
	 */
	public function cancel(resetValue:Bool=false):Void;
}
