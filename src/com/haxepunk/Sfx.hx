package com.haxepunk;

import nme.events.Event;
import nme.media.Sound;
import nme.media.SoundChannel;
import nme.media.SoundTransform;

typedef AudioCompleteCallback = Void -> Void;

/**
 * Sound effect object used to play embedded sounds.
 */
class Sfx
{
	/**
	 * Optional callback function for when the sound finishes playing.
	 */
	public var complete:AudioCompleteCallback;

	/**
	 * Creates a sound effect from an embedded source. Store a reference to
	 * this object so that you can play the sound using play() or loop().
	 * @param	source		The embedded sound class to use.
	 * @param	complete	Optional callback function for when the sound finishes playing.
	 */
	public function new(source:Dynamic, complete:AudioCompleteCallback = null)
	{
		_transform = new SoundTransform();
		_volume = 1;
		_pan = 0;
		_position = 0;

		if (source == null) throw "Invalid source Sound.";
#if nme
		if (Std.is(source, String))
		{
			_sound = nme.Assets.getSound(source);
			_sounds.set(source, _sound);
		}
		else
#end
		{
			var className:String = Type.getClassName(Type.getClass(source));
			_sound = _sounds.get(className);
			if (_sound == null)
			{
				_sound = source;
				_sounds.set(className, source);
			}
		}

		this.complete = complete;
	}

	/**
	 * Plays the sound once.
	 * @param	vol		Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function play(volume:Float = 1, pan:Float = 0)
	{
		if (playing) stop();
		_volume = _transform.volume = volume < 0 ? 0 : volume;
		_pan = _transform.pan = pan < -1 ? -1 : (pan > 1 ? 1 : pan);
		_channel = _sound.play(0, 0, _transform);
		if (playing) _channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		_looping = false;
		_position = 0;
	}

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	vol		Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(vol:Float = 1, pan:Float = 0)
	{
		play(vol, pan);
		_looping = true;
	}

	/**
	 * Stops the sound if it is currently playing.
	 * @return
	 */
	public function stop():Bool
	{
		if (!playing) return false;
		_position = _channel.position;
		_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
		_channel.stop();
		_channel = null;
		return true;
	}

	/**
	 * Resumes the sound from the position stop() was called on it.
	 */
	public function resume()
	{
		_channel = _sound.play(_position, 0, _transform);
		if (playing) _channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		_position = 0;
	}

	/** @private Event handler for sound completion. */
	private function onComplete(e:Event = null)
	{
		if (_looping) loop(_volume, _pan);
		else stop();
		_position = 0;
		if (complete != null) complete();
	}

	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	public var volume(getVolume, setVolume):Float;
	private function getVolume():Float { return _volume; }
	private function setVolume(value:Float):Float
	{
		if (value < 0) value = 0;
		if (_channel == null || _volume == value) return value;
		_volume = _transform.volume = value;
		_channel.soundTransform = _transform;
		return _volume;
	}

	/**
	 * Alter the panning factor (a value from -1 to 1) of the sound during playback.
	 */
	public var pan(getPan, setPan):Float;
	private function getPan():Float { return _pan; }
	private function setPan(value:Float):Float
	{
		if (value < -1) value = -1;
		if (value > 1) value = 1;
		if (_channel == null || _pan == value) return value;
		_pan = _transform.pan = value;
		_channel.soundTransform = _transform;
		return _pan;
	}

	/**
	 * If the sound is currently playing.
	 */
	public inline var playing(getPlaying, null):Bool;
	private inline function getPlaying():Bool { return _channel != null; }

	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(getPosition, null):Float;
	private function getPosition():Float { return (_channel != null ? _channel.position : _position) / 1000; }

	/**
	 * Length of the sound, in seconds.
	 */
	public var length(getLength, null):Float;
	private function getLength():Float { return _sound.length / 1000; }

	// Sound infromation.
	private var _volume:Float;
	private var _pan:Float;
	private var _sound:Sound;
	private var _channel:SoundChannel;
	private var _transform:SoundTransform;
	private var _position:Float;
	private var _looping:Bool;

	// Stored Sound objects.
	private static var _sounds:Hash<Sound> = new Hash<Sound>();
}