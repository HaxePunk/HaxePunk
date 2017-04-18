package haxepunk.graphics;

import flash.display.BlendMode;
import flash.geom.Point;
import haxe.ds.Either.Left;
import haxe.ds.Either.Right;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.graphics.BaseEmitter;
import haxepunk.graphics.atlas.AtlasRegion;
import haxepunk.utils.Color;
import haxepunk.utils.Ease;
import haxepunk.utils.MathUtil;
import haxepunk.utils.Random;

/**
 * Particle emitter used for emitting and rendering particle sprites.
 * Good rendering performance with large amounts of particles.
 */
class Emitter extends BaseEmitter<Spritemap>
{
	/**
	 * Constructor. Sets the source image to use for newly added particle types.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function new(source:TileType, frameWidth:Int = 0, frameHeight:Int = 0)
	{
		super(new Spritemap(source, frameWidth, frameHeight));
		_source.centerOrigin();
		_frames = new Map();
	}

	override public function addType(name:String, ?blendMode:BlendMode):ParticleType
	{
		return newType(name, blendMode);
	}

	/**
	 * Creates a new Particle type for this Emitter.
	 * @param	name		Name of the particle type.
	 * @param	frames		Array of frame indices for the particles to animate.
	 * @return	A new ParticleType object.
	 */
	public function newType(name:String, ?frames:Array<Int>, ?blendMode:BlendMode):ParticleType
	{
		var pt = super.addType(name, blendMode);
		if (frames == null) frames = new Array<Int>();
		if (frames.length == 0) frames.push(0);
		_frames.set(name, frames);
		return pt;
	}

	override function updateParticle(p:Particle, td:Float)
	{
		var type:ParticleType = p._type;
		var frames = _frames[type._name];
		var frame = Std.int(td * frames.length);
		if (frame >= frames.length - 1) frame = frames.length - 1;
		_source.frame = frames[frame];
	}

	// Source information.
	var _frames:Map<String, Array<Int>>;
	var _frameWidth:Int;
	var _frameHeight:Int;
}
