package haxepunk;

#if (lime || nme)

typedef Sfx = haxepunk.backend.flash.Sfx;

#else

class Sfx
{
	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	public var volume:Float;

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false) {}

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	vol		Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(vol:Float = 1, pan:Float = 0)
	{
		play(vol, pan, true);
	}

	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool
	{
		return false;
	}

	// TODO: This function needs to be removed!
	public static function onGlobalUpdated(updatePan:Bool) {}
}

#end
