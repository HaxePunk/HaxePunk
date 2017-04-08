package haxepunk.graphics;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Point;
import haxe.ds.Either;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.utils.Color;
import haxepunk.utils.Ease;
import haxepunk.utils.MathUtil;
import haxepunk.utils.Random;

/**
 * Particle emitter used for emitting and rendering particle sprites.
 * Good rendering performance with large amounts of particles.
 */
class Emitter extends Graphic
{
	/**
	 * Optional blend mode to use when drawing this image.
	 * Use constants from the flash.display.BlendMode class.
	 */
	public var blend:BlendMode;

	/**
	 * Constructor. Sets the source image to use for newly added particle types.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function new(source:ImageOrTileType, frameWidth:Int = 0, frameHeight:Int = 0)
	{
		super();
		_types = new Map<String, ParticleType>();

		setSource(source, frameWidth, frameHeight);
		active = true;
		particleCount = 0;

		smooth = (HXP.stage.quality != LOW);
	}

	/**
	 * Changes the source image to use for newly added particle types.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function setSource(source:ImageOrTileType, frameWidth:Int = 0, frameHeight:Int = 0)
	{
		switch (source)
		{
			case Left(img):
				_source = new Image(img);
				_animated = false;
				blit = false;
			case Right(tile):
				_source = new Spritemap(tile, frameWidth, frameHeight);
				_animated = true;
				blit = _source.blit;
		}
		_source.centerOrigin();
	}

	override public function update()
	{
		// quit if there are no particles
		if (_particle == null) return;

		// particle info
		var p:Particle = _particle,
			n:Particle;

		// loop through the particles
		while (p != null)
		{
			p._time += HXP.elapsed; // Update particle time elapsed

			var type = p._type;
			var t = p._time / p._duration;

			if (p._time - (type._trailLength * type._trailDelay) >= p._stopTime)
			{
				if (p._next != null) p._next._prev = p._prev;
				if (p._prev != null) p._prev._next = p._next;
				else _particle = p._next;
				n = p._next;
				p._next = _cache;
				p._prev = null;
				_cache = p;
				p = n;
				particleCount--;
				continue;
			}

			// get next particle
			p = p._next;
		}
	}

	/**
	 * Clears all particles.
	 * @since	2.5.2
	 */
	public function clear()
	{
		// quit if there are no particles
		if (_particle == null)
		{
			return;
		}

		// particle info
		var p:Particle = _particle,
			n:Particle;

		// loop through the particles
		while (p != null)
		{
			// move this particle to the cache
			n = p._next;
			p._next = _cache;
			p._prev = null;
			_cache = p;
			p = n;
			particleCount--;
		}

		_particle = null;
	}

	function renderParticles(buffer:Bool, target:BitmapData, layer:Int, point:Point, camera:Camera)
	{
		var p:Particle = _particle;

		var t:Float,
			pt:Float,
			type:ParticleType,
			td:Float,
			atd:Float,
			std:Float,
			rtd:Float,
			ctd:Float;

		// loop through the particles
		while (p != null)
		{
			// get time scale
			t = p._time / p._duration;
			if (p._firstDraw)
			{
				p._ox = point.x;
				p._oy = point.y;
				p._firstDraw = false;
			}

			// get particle type
			type = p._type;

			_source.smooth = smooth;
			_source.blend = type._blendMode == null ? this.blend : type._blendMode;

			var n:Int = type._trailLength;
			while (n >= 0)
			{
				pt = p._time - (n--) * type._trailDelay;
				t = pt / p._duration;
				if (t < 0 || pt >= p._stopTime) continue;
				td = type._ease != null ? type._ease(t) : t;
				atd = type._alphaEase != null ? type._alphaEase(t) : t;
				std = type._scaleEase != null ? type._scaleEase(t) : t;
				rtd = type._rotationEase != null ? type._rotationEase(t) : t;
				ctd = type._colorEase != null ? type._colorEase(t) : t;

				if (_animated)
				{
					var frame = Std.int(td * type._frames.length);
					if (frame >= type._frames.length - 1) frame = type._frames.length - 1;
					var spritemap:Spritemap = cast _source;
					spritemap.frame = type._frames[frame];
				}
				_source.angle = p.angle(rtd);
				_source.color = p.color(ctd);
				_source.alpha = p.alpha(atd) * Math.pow(type._trailAlpha, n);
				_source.scale = scale * p.scale(std);
				_source.x = p.x(td) - point.x;
				_source.y = p.y(td) - point.y;

				if (buffer) _source.render(target, point, camera);
				else _source.renderAtlas(layer, point, camera);
			}

			// get next particle
			p = p._next;
		}
	}

	override public function render(target:BitmapData, point:Point, camera:Camera)
	{
		renderParticles(true, target, -1, point, camera);
	}

	override public function renderAtlas(layer:Int, point:Point, camera:Camera)
	{
		renderParticles(false, null, layer, point, camera);
	}

	/**
	 * Creates a new Particle type for this Emitter.
	 * @param	name		Name of the particle type.
	 * @param	frames		Array of frame indices for the particles to animate.
	 * @return	A new ParticleType object.
	 */
	public function newType(name:String, frames:Array<Int> = null, ?blendMode:BlendMode):ParticleType
	{
		var pt:ParticleType = _types.get(name);

		if (pt != null)
			throw "Cannot add multiple particle types of the same name";

		pt = new ParticleType(name, frames, _width, _frameWidth, _frameHeight, blendMode);
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
	 * @param	ease			Optional ease function.
	 * @param	backwards		If the motion should be played backwards.
	 * @return	This ParticleType object.
	 */
	public function setMotion(name:String, angle:Float, distance:Float, duration:Float, angleRange:Float = 0, distanceRange:Float = 0, durationRange:Float = 0, ?ease:EaseFunction, backwards:Bool = false):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setMotion(angle, distance, duration, angleRange, distanceRange, durationRange, ease, backwards);
	}

	/**
	 * Sets the gravity range for a particle type.
	 * @param	name      		The particle type.
	 * @param	gravity      	Gravity amount to affect to the particle y velocity.
	 * @param	gravityRange	Random amount to add to the particle's gravity.
	 * @return	This ParticleType object.
	 */
	public function setGravity(name:String, ?gravity:Float = 0, ?gravityRange:Float = 0):ParticleType
	{
		return _types.get(name).setGravity(gravity, gravityRange);
	}

	/**
	 * Sets the alpha range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting alpha.
	 * @param	finish		The finish alpha.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setAlpha(name:String, start:Float = 1, finish:Float = 0, ?ease:EaseFunction):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setAlpha(start, finish, ease);
	}

	/**
	 * Sets the scale range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting scale.
	 * @param	finish		The finish scale.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 * @since	2.6.0
	 */
	public function setScale(name:String, start:Float = 1, finish:Float = 0, ?ease:EaseFunction):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setScale(start, finish, ease);
	}

	/**
	 * Defines the rotation range for a particle type.
	 * @param	name	The particle type.
	 * @param	startAngle	Starting angle.
	 * @param	spanAngle	Total amount of degrees to rotate.
	 * @param	startAngleRange	Random amount to add to the particle's starting angle.
	 * @param	spanAngleRange	Random amount to add to the particle's span angle.
	 * @param	ease	Optional easer function.
	 * @since	2.6.0
	 * @return	This ParticleType object.
	 */
	public function setRotation(name:String, startAngle:Float, spanAngle:Float, startAngleRange:Float = 0, spanAngleRange:Float = 0, ease:EaseFunction = null):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setRotation(startAngle, spanAngle, startAngleRange, spanAngleRange, ease);
	}

	/**
	 * Sets the trail of the particle type.
	 * @param	name		The particle type.
	 * @param	length		Number of trailing particles to draw.
	 * @param	delay		Time to delay each trailing particle, in seconds.
	 * @param	alpha		Multiply each successive trail particle's alpha by this amount.
	 * @since	2.6.0
	 * @return	This ParticleType object.
	 */
	public function setTrail(name:String, length:Int = 1, delay:Float = 0.1, alpha:Float=1):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setTrail(length, delay, alpha);
	}

	/**
	 * Sets the color range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting color.
	 * @param	finish		The finish color.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setColor(name:String, start:Color = Color.White, finish:Color = Color.Black, ?ease:EaseFunction):ParticleType
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
	 * @param	angle		Base angle to start from.
	 * @return	The Particle emited.
	 */
	public function emit(name:String, x:Float = 0, y:Float = 0, angle:Float = 0):Particle
	{
		var p:Particle, type:ParticleType = _types.get(name);

		if (type == null)
			throw "Particle type \"" + name + "\" does not exist.";

		if (_cache != null)
		{
			p = _cache;
			_cache = p._next;
		}
		else
		{
			p = new Particle();
		}
		p._next = _particle;
		p._prev = null;
		if (p._next != null) p._next._prev = p;

		p._type = type;
		p._time = 0;
		p._duration = type._duration + type._durationRange * Random.random;
		p._stopTime = p._duration;
		p._angle = angle + type._angle + type._angleRange * Random.random;
		p._startAngle = type._startAngle + type._startAngleRange * Random.random;
		p._spanAngle = type._spanAngle + type._spanAngleRange * Random.random;
		var d:Float = type._distance + type._distanceRange * Random.random;
		p._moveX = Math.cos(p._angle * MathUtil.RAD) * d;
		p._moveY = Math.sin(p._angle * MathUtil.RAD) * d;
		p._x = x;
		p._y = y;
		p._gravity = type._gravity + type._gravityRange * Random.random;
		p._firstDraw = true;
		p._ox = p._oy = 0;
		particleCount++;
		return (_particle = p);
	}

	/**
	 * Randomly emits the particle inside the specified radius
	 * @param	name		Particle type to emit.
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @param	radius		Radius to emit inside.
	 *
	 * @return The Particle emited.
	 */
	public function emitInCircle(name:String, x:Float, y:Float, radius:Float):Particle
	{
		var angle = Random.random * Math.PI * 2;
		radius *= Random.random;
		return emit(name, x + Math.cos(angle) * radius, y + Math.sin(angle) * radius);
	}

	/**
	 * Randomly emits the particle inside the specified area
	 * @param	name		Particle type to emit
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @param	width		Width of the area to emit from.
	 * @param	height		height of the area to emit from.
	 *
	 * @return The Particle emited.
	 */
	public function emitInRectangle(name:String, x:Float, y:Float, width:Float, height:Float):Particle
	{
		return emit(name, x + Random.random * width, y + Random.random * height);
	}

	/**
	 * Amount of currently existing particles.
	 */
	public var particleCount(default, null):Int;

	public var scale:Float = 1;
	public var smooth:Bool = true;

	// Particle information.
	var _types:Map<String, ParticleType>;
	var _particle:Particle;
	var _cache:Particle;

	// Source information.
	var _source:Image;
	var _animated:Bool = false;
	var _width:Int;
	var _height:Int;
	var _frameWidth:Int;
	var _frameHeight:Int;
	var _frameCount:Int;
	var _frames:Array<AtlasRegion>;
}
