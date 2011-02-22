package com.haxepunk.graphics;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Ease;

/**
 * Particle emitter used for emitting and rendering particle sprites.
 * Good rendering performance with large amounts of particles.
 */
class Emitter extends Graphic
{
	/**
	 * Constructor. Sets the source image to use for newly added particle types.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function new(source:BitmapData, frameWidth:Int = 0, frameHeight:Int = 0) 
	{
		super();
		_p = new Point();
		_tint = new ColorTransform();
		_types = new Hash<ParticleType>();
		
		setSource(source, frameWidth, frameHeight);
		active = true;
	}
	
	/**
	 * Changes the source image to use for newly added particle types.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function setSource(source:BitmapData, frameWidth:Int = 0, frameHeight:Int = 0)
	{
		_source = source;
		if (_source == null) throw "Invalid source image.";
		_width = _source.width;
		_height = _source.height;
		_frameWidth = (frameWidth != 0) ? frameWidth : _width;
		_frameHeight = (frameHeight != 0) ? frameHeight : _height;
		_frameCount = Std.int(_width / _frameWidth) * Std.int(_height / _frameHeight);
	}
	
	override public function update() 
	{
		// quit if there are no particles
		if (_particle == null) return;
		
		// particle info
		var e:Float = HXP.fixed ? 1 : HXP.elapsed,
			p:Particle = _particle,
			n:Particle, t:Float;
		
		// loop through the particles
		while (p != null)
		{
			// update time scale
			p._time += e;
			t = p._time / p._duration;
			
			// remove on time-out
			if (p._time >= p._duration)
			{
				if (p._next != null) p._next._prev = p._prev;
				if (p._prev != null) p._prev._next = p._next;
				else _particle = p._next;
				n = p._next;
				p._next = _cache;
				p._prev = null;
				_cache = p;
				p = n;
				_particleCount --;
				continue;
			}
			
			// get next particle
			p = p._next;
		}
	}
	
	/** @private Renders the particles. */
	override public function render(target:BitmapData, point:Point, camera:Point) 
	{
		// quit if there are no particles
		if (_particle == null) return;
		
		// get rendering position
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;
		
		// particle info
		var t:Float, td:Float,
			p:Particle = _particle,
			type:ParticleType,
			rect:Rectangle;
		
		// loop through the particles
		while (p != null)
		{
			// get time scale
			t = p._time / p._duration;
			
			// get particle type
			type = p._type;
			rect = type._frame;
			
			// get position
			td = (type._ease == null) ? t : type._ease(t);
			_p.x = _point.x + p._x + p._moveX * td;
			_p.y = _point.y + p._y + p._moveY * td;
			
			// get frame
			rect.x = rect.width * type._frames[Std.int(td * type._frameCount)];
			rect.y = Std.int(rect.x / type._width) * rect.height;
			rect.x %= type._width;
			
			// draw particle
			if (type._buffer != null)
			{
				// get alpha
				_tint.alphaMultiplier = type._alpha + type._alphaRange * ((type._alphaEase == null) ? t : type._alphaEase(t));
				
				// get color
				td = (type._colorEase == null) ? t : type._colorEase(t);
				_tint.redMultiplier = type._red + type._redRange * td;
				_tint.greenMultiplier = type._green + type._greenRange * td;
				_tint.blueMultiplier  = type._blue + type._blueRange * td;
				type._buffer.fillRect(type._bufferRect, 0);
				type._buffer.copyPixels(type._source, rect, HXP.zero);
				type._buffer.colorTransform(type._bufferRect, _tint);
				
				// draw particle
				target.copyPixels(type._buffer, type._bufferRect, _p, null, null, true);
			}
			else target.copyPixels(type._source, rect, _p, null, null, true);
			
			// get next particle
			p = p._next;
		}
	}
	
	/**
	 * Creates a new Particle type for this Emitter.
	 * @param	name		Name of the particle type.
	 * @param	frames		Array of frame indices for the particles to animate.
	 * @return	A new ParticleType object.
	 */
	public function newType(name:String, frames:Array<Int> = null):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt != null) throw "Cannot add multiple particle types of the same name";
		pt = new ParticleType(name, frames, _source, _frameWidth, _frameHeight);
		_types.set(name, pt);
		return pt;
	}
	
	/**
	 * Defines the motion range for a particle type.
	 * @param	name			The particle type.
	 * @param	angle			Launch Direction.
	 * @param	distance		Distance to travel.
	 * @param	duration		Particle duration.
	 * @param	angleRange		Random amount to add to the particle's direction.
	 * @param	distanceRange	Random amount to add to the particle's distance.
	 * @param	durationRange	Random amount to add to the particle's duration.
	 * @param	ease			Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setMotion(name:String, angle:Float, distance:Float, duration:Float, angleRange:Float = 0, distanceRange:Float = 0, durationRange:Float = 0, ease:EaseFunction = null):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setMotion(angle, distance, duration, angleRange, distanceRange, durationRange, ease);
	}
	
	/**
	 * Sets the alpha range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting alpha.
	 * @param	finish		The finish alpha.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setAlpha(name:String, start:Float = 1, finish:Float = 0, ease:EaseFunction = null):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setAlpha(start, finish, ease);
	}
	
	/**
	 * Sets the color range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting color.
	 * @param	finish		The finish color.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setColor(name:String, start:Int = 0xFFFFFF, finish:Int = 0, ease:EaseFunction = null):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setColor(start, finish, ease);
	}
	
	/**
	 * Emits a particle.
	 * @param	name		Particle type to emit.
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @return
	 */
	public function emit(name:String, x:Float, y:Float):Particle
	{
		var p:Particle, type:ParticleType = _types.get(name);
		if (type == null) throw "Particle type \"" + name + "\" does not exist.";
		
		if (_cache != null)
		{
			p = _cache;
			_cache = p._next;
		}
		else p = new Particle();
		p._next = _particle;
		p._prev = null;
		if (p._next != null) p._next._prev = p;
		
		p._type = type;
		p._time = 0;
		p._duration = type._duration + type._durationRange * HXP.random;
		var a:Float = type._angle + type._angleRange * HXP.random,
			d:Float = type._distance + type._distanceRange * HXP.random;
		p._moveX = Math.cos(a) * d;
		p._moveY = Math.sin(a) * d;
		p._x = x;
		p._y = y;
		_particleCount ++;
		return (_particle = p);
	}
	
	/**
	 * Amount of currently existing particles.
	 */
	public var particleCount(getParticleCount, null):Int;
	private function getParticleCount():Int { return _particleCount; }
	
	// Particle infromation.
	private var _types:Hash<ParticleType>;
	private var _particle:Particle;
	private var _cache:Particle;
	private var _particleCount:Int;
	
	// Source information.
	private var _source:BitmapData;
	private var _width:Int;
	private var _height:Int;
	private var _frameWidth:Int;
	private var _frameHeight:Int;
	private var _frameCount:Int;
	
	// Drawing information.
	private var _p:Point;
	private var _tint:ColorTransform;
	private static inline var SIN:Float = Math.PI / 2;
}