package com.haxepunk;

import openfl.Assets;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import lime.audio.openal.AL;

/**
 * Sound effect object used to play embedded sounds.
 */
 @:access(openfl.media.SoundChannel)
 @:access(lime.audio.AudioSource)
 @:access(lime._backend.native.NativeAudioSource)
class Sfx
{
	/**
	 * Creates a sound effect from an embedded source. Store a reference to
	 * this object so that you can play the sound using play() or loop().
	 * @param	source		The embedded sound class to use.
	 * @param	complete	Optional callback function for when the sound finishes playing.
	 */
	public function new(source:Dynamic, ?complete:Void -> Void)
	{
		_transform = new SoundTransform();
		_volume = 1;
		_pan = 0;
		_position = 0;
		_type = "";

		if(source == null)
			throw "Invalid source sound.";

		if(Std.is(source, String))
		{
			// Load a sound asset
			_sound = Assets.getSound(source);
			_sounds.set(source, _sound);
		}
		else
		{
			// Load an openfl.media.Sound object
			var className = Type.getClassName(Type.getClass(source));
			if(StringTools.endsWith(className, "media.Sound"))
			{
				var __sound:Sound = cast source;
				_sound = _sounds.get(__sound.url);
				if(_sound == null)
				{
					_sound = source;
					_sounds.set(__sound.url, source);
				}
			}
			else
				throw "Invalid source sound.";
		}

		_complete = complete;
	}
	
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
	 * Plays the sound once or looped.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop indefinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false)
	{
		if (_sound == null)
		{
			trace("Sound is null");
			return;
		}
		if (playing) stop();
		_pan = HXP.clamp(pan, -1, 1);
		_volume = volume < 0 ? 0 : volume;
		_filteredPan = HXP.clamp(_pan + getPan(_type), -1, 1);
		_filteredVol = Math.max(0, _volume * getVolume(_type));
		_transform.pan = _filteredPan;
		_transform.volume = _filteredVol;
		_channel = _sound.play(0, 0, _transform);
		_looping = loop;
		_position = 0;
		
		if (playing)
		{
			addPlaying();
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}
	}
	
	/** @private Add the sound to a list of those currently playing. */
	private function addPlaying()
	{
		var list:Array<Sfx>;
		if (!_playingTypes.exists(_type))
		{
			list = new Array<Sfx>();
			_playingTypes.set(_type, list);
		}
		else
		{
			list = _playingTypes.get(_type);
		}
		list.push(this);
	}
	
	/** @private Removes the sound from the list of those currently playing. */
	private function removePlaying()
	{
		if (_playingTypes.exists(_type))
		{
			_playingTypes.get(_type).remove(this);
		}
	}
	
	/**
	 * Resumes the sound from the position stop() was called on it.
	 */
	public function resume()
	{
		_channel = _sound.play(_position, 0, _transform);
		if (playing)
		{
			addPlaying();
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}
	}
	
	/** @private Event handler for sound completion. */
	private function onComplete(_:Event)
	{
		stop();
		if (_looping)
		{
			trace("Repeating sound");
			_channel = _sound.play(0, 0, _transform);
			if(playing)
			{
				addPlaying();
				_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
			}
		}
		
		_position = 0;
		if (_complete != null) _complete();
	}
	
	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool
	{
		if (!playing) return false;
		removePlaying();
		_position = _channel.position;
		_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
		_channel.stop();
		_channel = null;
		return true;
	}

	
	/**
	 * Length of the sound, in seconds.
	 */
	public var length(get, null):Float;
	private function get_length() : Float { return _sound.length / 1000; }
	
	/**
	 * Alter the panning factor (a value from -1 to 1) of the sound during playback.
	 * Panning only applies to mono sounds. It is ignored on stereo.
	 */
	public var pan(get, set):Float;
	private function get_pan():Float { return _pan; }
	private function set_pan(value:Float):Float
	{
		value = HXP.clamp(value, -1, 1);
		if (_channel == null) return value;
		var filteredPan:Float = HXP.clamp(value + getPan(_type), -1, 1);
		if (_filteredPan == filteredPan) return value;
		_pan = value;
		_filteredPan = _transform.pan = filteredPan;
		_channel.soundTransform = _transform;
		return _pan;
	}
	
	/**
	 * Change the pitch of the sound during playback.
	 */
	public var pitch(get, set):Float;
	private function get_pitch() : Float
	{
		#if flash
		return 1.;
		#elseif (html5 || js)
		return 1.;
		#else
		if(_channel != null)
		{
			var h = _channel.__source.backend.handle;
			return AL.getSourcef(h, AL.PITCH);
		}
		return 1.;
		#end
	}
	private function set_pitch(v:Float) : Float
	{
		#if flash
		return 1.;
		#elseif (html5 || js)
		return 1.;
		#else
		if(_channel != null)
		{
			var h = _channel.__source.backend.handle;
			AL.sourcef(h, AL.PITCH, v);
			return v;
		}
		return 1.;
		#end
	}
	
	/**
	 * If the sound is currently playing.
	 */
	public var playing(get, null):Bool;
	private inline function get_playing():Bool { return _channel != null; }
	
	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(get, null):Float;
	private function get_position():Float { return (playing ? _channel.position : _position) / 1000; }
	
	/**
	 * Change the sound type. This an arbitrary string you can use to group
	 * sounds to mute or pan en masse.
	 */
	public var type(get, set):String;
	private function get_type():String { return _type; }
	private function set_type(value:String):String
	{
		if (_type == value) return value;
		if (playing)
		{
			removePlaying();
			addPlaying();
			// reset, in case sound type has different settings
			pan = pan;
			volume = volume;
		}
		
		_type = value;
		
		return value;
	}
	
	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	public var volume(get, set):Float;
	private function get_volume():Float { return _volume; }
	private function set_volume(value:Float):Float
	{
		if (value < 0) value = 0;
		_volume = value;
		var filteredVol:Float = value * getVolume(_type);
		if (filteredVol < 0) filteredVol = 0;
		if (_filteredVol == filteredVol) return value;
		_filteredVol = _transform.volume = filteredVol;
		if(_channel != null) _channel.soundTransform = _transform;
		return _volume;
	}
	
	/**
	 * Return a sound type's pan setting. 
	 * On non-flash targets, this factors in global panning. See `HXP.pan`.
	 *
	 * @param	type	The type to get the pan from.
	 *
	 * @return	The pan for the type.
	 */
	static public function getPan(type:String) : Float
	{
		if(_transformTypes.exists(type))
		{
			var t = _transformTypes.get(type);
			if(t != null)
				return t.pan #if !flash * HXP.pan #end;
		}
		return 0;
	}
	
	/**
	 * Return a sound type's volume setting.
	 * On non-flash targets, this factors in global volume. See `HXP.volume`.
	 *
	 * @param	type	The type to get the volume from.
	 *
	 * @return	The volume for the type.
	 */
	static public function getVolume(type:String) : Float
	{
		if(_transformTypes.exists(type))
		{
			var t = _transformTypes.get(type);
			if(t != null)
				return t.volume #if !flash * HXP.volume #end;
		}
		return 1.;
	}
	
	/**
	 * Set a sound type's pan. Sfx instances of this type will add
	 * this pan to their own.
	 *
	 * @param	type	The type to set.
	 * @param	pan		The pan value.
	 */
	static public function setPan(type:String, v:Float)
	{
		var t = _transformTypes.get(type);
		if(t == null)
		{
			t = new SoundTransform();
			_transformTypes.set(type, t);
		}
		t.pan = HXP.clamp(v, -1., 1.);
		
		if(_playingTypes.exists(type))
		{
			for(sfx in _playingTypes.get(type))
				sfx.pan = sfx.pan;
		}
	}
	
	/**
	 * Set a sound type's volume. Sfx instances of this type will multiply
	 * this volume to their own.
	 *
	 * @param	type	The type to set.
	 * @param	volume	The volume value.
	 */
	static public function setVolume(type:String, v:Float)
	{
		var t = _transformTypes.get(type);
		if(t == null)
		{
			t = new SoundTransform();
			_transformTypes.set(type, t);
		}
		t.volume = v < 0 ? 0 : v;
		
		if(_playingTypes.exists(type))
		{
			for(sfx in _playingTypes.get(type))
				sfx.volume = sfx.volume;
		}
	}
	
	/**
	 * Called by `HXP` when global volume or panning are changed
	 * on native targets. Updates all sounds to the correct volume
	 * or pan, depending on the updatePan setting.
	 *
	 * @param	updatePan	True indicates pan changed, false indicates volume changed.
	 */
	static public function onGlobalUpdated(updatePan:Bool)
	{
		for(type in _playingTypes.keys())
		{
			for(sfx in _playingTypes.get(type))
			{
				if(updatePan)
					sfx.pan = sfx.pan;
				else
					sfx.volume = sfx.volume;
			}
		}
	}
	
	// Sound infromation.
	private var _type:String;
	private var _volume:Float = 1;
	private var _pan:Float = 0;
	private var _filteredVol:Float = 1;
	private var _filteredPan:Float = 0;
	private var _sound:Sound;
	public var _channel:SoundChannel;
	private var _transform:SoundTransform;
	private var _position:Float = 0;
	private var _looping:Bool;
	/**
	 * Optional callback function for when the sound finishes playing.
	 */
	@:dox(hide) // mistaken for a class function
	public var _complete:Void -> Void;
	
	// Stored sound objects
	static private var _sounds:Map<String, Sound> = new Map<String, Sound>();
	static private var _playingTypes:Map<String, Array<Sfx>> = new Map<String, Array<Sfx>>();
	static private var _transformTypes:Map<String, SoundTransform> = new Map<String, SoundTransform>();
}
