package haxepunk.graphics.emitter;

import haxepunk.utils.BlendMode;
import haxepunk.utils.Color;
import haxepunk.utils.Ease.EaseFunction;

/**
 * Template used to define a particle type used by the Emitter class. Instead
 * of creating this object yourself, fetch one with Emitter's add() function.
 */
@:allow(haxepunk.graphics.emitter.BaseEmitter)
class ParticleType
{
	public inline function ease(?f:EaseFunction, t:Float):Float
	{
		return f == null ? t : f(t);
	}

	/**
	 * Constructor.
	 * @param	name			Name of the particle type.
	 * @param	frames			Array of frame indices to animate through.
	 * @param	width			Unused parameter.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function new(name:String, blendMode:BlendMode)
	{
		_red = _green = _blue = _alpha = _scale = _trailLength = 1;
		_blendMode = blendMode;
		_redRange = _greenRange = _blueRange = _alphaRange = _scaleRange = _trailDelay = 0;
		_trailAlpha = 1;
		_startAngle = _spanAngle = _startAngleRange = _spanAngleRange = 0;

		_name = name;

		_angle    = _angleRange    = 0;
		_gravity  = _gravityRange  = 0;
		_duration = _durationRange = 0;
		_distance = _distanceRange = 0;
	}

	/**
	 * Defines the motion range for this particle type.
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
	public function setMotion(angle:Float, distance:Float, duration:Float, angleRange:Float = 0, distanceRange:Float = 0, durationRange:Float = 0, ?ease:EaseFunction, backwards:Bool = false):ParticleType
	{
		_angle = angle;
		_distance = distance;
		_duration = duration;
		_angleRange = angleRange;
		_distanceRange = distanceRange;
		_durationRange = durationRange;
		_ease = ease;
		_backwards = backwards;
		return this;
	}

	/**
	 * Defines the motion range for this particle type based on the vector.
	 * @param	x				X distance to move.
	 * @param	y				Y distance to move.
	 * @param	duration		Particle duration.
	 * @param	durationRange	Random amount to add to the particle's duration.
	 * @param	ease			Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setMotionVector(x:Float, y:Float, duration:Float, durationRange:Float = 0, ?ease:EaseFunction):ParticleType
	{
		_angle = Math.atan2(y, x);
		_angleRange = 0;
		_duration = duration;
		_durationRange = durationRange;
		_ease = ease;
		return this;
	}

	/**
	* Sets the gravity range of this particle type.
	* @param	gravity			Gravity amount to affect to the particle y velocity.
	* @param	gravityRange	Random amount to add to the particle's gravity.
	* @return	This ParticleType object.
	*/
	public function setGravity(gravity:Float = 0, gravityRange:Float = 0):ParticleType
	{
		_gravity = gravity;
		_gravityRange = gravityRange;
		return this;
	}

	/**
	 * Sets the alpha range of this particle type.
	 * @param	start		The starting alpha.
	 * @param	finish		The finish alpha.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setAlpha(start:Float = 1, finish:Float = 0, ?ease:EaseFunction):ParticleType
	{
		start = start < 0 ? 0 : (start > 1 ? 1 : start);
		finish = finish < 0 ? 0 : (finish > 1 ? 1 : finish);
		_alpha = start;
		_alphaRange = finish - start;
		_alphaEase = ease;
		return this;
	}

	/**
	 * Sets the scale range of this particle type.
	 * @param	start		The starting scale.
	 * @param	finish		The finish sale.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setScale(start:Float = 1, finish:Float = 0, ?ease:EaseFunction):ParticleType
	{
		_scale = start;
		_scaleRange = finish - start;
		_scaleEase = ease;
		return this;
	}

	/**
	 * Sets the rotation range of this particle type.
	 * @param	startAngle	Starting angle.
	 * @param	spanAngle	Total amount of degrees to rotate.
	 * @param	startAngleRange	Random amount to add to the particle's starting angle.
	 * @param	spanAngleRange	Random amount to add to the particle's span angle.
	 * @param	ease	Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setRotation(startAngle:Float, spanAngle:Float, startAngleRange:Float = 0, spanAngleRange:Float = 0, ?ease:EaseFunction):ParticleType
	{
		_startAngle = startAngle;
		_spanAngle = spanAngle;
		_startAngleRange = startAngleRange;
		_spanAngleRange = spanAngleRange;
		_rotationEase = ease;
		return this;
	}

	/**
	 * Sets the color range of this particle type.
	 * @param	start		The starting color.
	 * @param	finish		The finish color.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setColor(start:Color = 0xFFFFFF, finish:Color = 0, ?ease:EaseFunction):ParticleType
	{
		start &= 0xFFFFFF;
		finish &= 0xFFFFFF;
		_red = (start >> 16 & 0xFF) / 255;
		_green = (start >> 8 & 0xFF) / 255;
		_blue = (start & 0xFF) / 255;
		_redRange = (finish >> 16 & 0xFF) / 255 - _red;
		_greenRange = (finish >> 8 & 0xFF) / 255 - _green;
		_blueRange = (finish & 0xFF) / 255 - _blue;
		_colorEase = ease;
		return this;
	}

	/**
	 * Sets the trail of this particle type.
	 * @param	length		Number of trailing particles to draw.
	 * @param	delay		Time to delay each trailing particle, in seconds.
	 * @param	alpha		Multiply each successive trail particle's alpha by this amount.
	 * @return	This ParticleType object.
	 */
	public function setTrail(length:Int = 1, delay:Float = 0.1, alpha:Float = 1):ParticleType
	{
		_trailLength = length;
		_trailDelay = delay;
		_trailAlpha = alpha;
		return this;
	}

	// Particle information.
	var _name:String;
	var _blendMode:Null<BlendMode>;

	// Motion information.
	var _angle:Float;
	var _angleRange:Float;
	var _distance:Float;
	var _distanceRange:Float;
	var _duration:Float;
	var _durationRange:Float;
	var _ease:EaseFunction;
	var _backwards:Bool;

	// Gravity information.
	var _gravity:Float;
	var _gravityRange:Float;

	// Alpha information.
	var _alpha:Float;
	var _alphaRange:Float;
	var _alphaEase:EaseFunction;

	// Scale information.
	var _scale:Float;
	var _scaleRange:Float;
	var _scaleEase:EaseFunction;

	// Rotation information.
	var _startAngle:Float;
	var _spanAngle:Float;
	var _startAngleRange:Float;
	var _spanAngleRange:Float;
	var _rotationEase:EaseFunction;

	// Color information.
	var _red:Float;
	var _redRange:Float;
	var _green:Float;
	var _greenRange:Float;
	var _blue:Float;
	var _blueRange:Float;
	var _colorEase:EaseFunction;

	// Trail information
	var _trailLength:Int;
	var _trailDelay:Float;
	var _trailAlpha:Float;
}
