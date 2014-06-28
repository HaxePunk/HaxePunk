package haxepunk;

import lime.Assets;

class Sound
{

	public function new(path:String)
	{
		_sound = Assets.getSound(path);
	}

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false):Void
	{
		_sound.volume = volume;
		_sound.pan = pan;
		_sound.looping = loop;
		_sound.play();
	}

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	volume	Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(volume:Float = 1, pan:Float = 0):Void
	{
		play(volume, pan, true);
	}

	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool
	{
		if (!_sound.playing) return false;
		_sound.stop();
		return true;
	}

	/**
	 * Resumes the sound from the position stop() was called on it.
	 */
	public function resume():Void
	{
	}

	/**
	 * If the sound is currently playing.
	 */
	public var playing(get, never):Bool;
	private inline function get_playing():Bool { return _sound.playing; }

	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(get, never):Float;
	private inline function get_position():Float { return _sound.position; }

	private var _sound:lime.Sound;

}
