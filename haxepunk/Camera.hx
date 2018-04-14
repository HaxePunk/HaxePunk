package haxepunk;

import haxepunk.math.Vector2;

/**
 * @since 4.0.0
 */
class Camera
{
	public var x:Float = 0;
	public var y:Float = 0;

	public var scale:Float = 1;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	public function new(x:Float = 0, y:Float = 0)
	{
		this.x = x;
		this.y = y;
	}

	/**
	 * Set the Camera's position. If provided, px and py determine the part of
	 * the screen to move to the given position; 0.5 will center the camera,
	 * and 1.0 will set the right edge.
	 */
	public inline function setTo(x:Float, y:Float, px:Float = 0, py:Float = 0)
	{
		this.x = x - ((HXP.width / fullScaleX) * px);
		this.y = y - ((HXP.height / fullScaleY) * py);
	}

	/**
	 * Whether this graphic will be snapped to the nearest whole number pixel
	 * position when rendering. If this is true for either an individual
	 * Graphic or for the Camera, snapping will occur.
	 */
	public var pixelSnapping:Bool = false;

	public var fullScaleX(get, never):Float;
	inline function get_fullScaleX() return scale * scaleX;
	public var fullScaleY(get, never):Float;
	inline function get_fullScaleY() return scale * scaleY;

	public var screenScaleX(get, never):Float;
	inline function get_screenScaleX() return fullScaleX * HXP.screen.scaleX;
	public var screenScaleY(get, never):Float;
	inline function get_screenScaleY() return fullScaleY * HXP.screen.scaleY;

	public var width(get, never):Float;
	inline function get_width() return HXP.screen.width / screenScaleX;

	public var height(get, never):Float;
	inline function get_height() return HXP.screen.height / screenScaleY;

	/**
	 * Return an X value that, after scaling, will result in an integer.
	 */
	public inline function floorX(x:Float) return Math.floor((x + 0.5) * screenScaleX) / screenScaleX;
	/**
	 * Return a Y value that, after scaling, will result in an integer.
	 */
	public inline function floorY(y:Float) return Math.floor((y + 0.5) * screenScaleY) / screenScaleY;

	var anchorTarget:Null<Vector2>;
	var anchorX:Float = 0;
	var anchorY:Float = 0;

	/**
	 * Anchor the Camera to an Entity or other object with position. The
	 * Camera will keep the target in the specified part of the screen.
	 * @since 4.0.0
	 */
	public function anchor(?target:Vector2, anchorX:Float = 0.5, anchorY:Float = 0.5)
	{
		anchorTarget = target;
		this.anchorX = anchorX;
		this.anchorY = anchorY;
	}

	public function onCamera(entity:Entity):Bool
	{
		return entity.collideRect(entity.x, entity.y, x, y, HXP.width, HXP.height);
	}

	/**
	 * Cause the screen to shake for a specified length of time.
	 * @param	duration	Duration of shake effect, in seconds.
	 * @param	magnitude	Number of pixels to shake in any direction.
	 * @since	2.5.3
	 */
	public function shake(duration:Float = 0.5, magnitude:Int = 4)
	{
		if (_shakeTime < duration) _shakeTime = duration;
		_shakeMagnitude = magnitude;
	}

	/**
	 * Stop the screen from shaking immediately.
	 * @since	2.5.3
	 */
	public function shakeStop()
	{
		_shakeTime = 0;
	}

	public function update()
	{
		if (anchorTarget != null)
		{
			var tx = anchorTarget.x,
				ty = anchorTarget.y;
			if (Std.is(anchorTarget, Entity))
			{
				var e:Entity = cast anchorTarget;
				tx = e.centerX;
				ty = e.centerY;
			}
			x = tx - (HXP.width / fullScaleX * anchorX);
			y = ty - (HXP.height / fullScaleY * anchorY);
		}

		// screen shake
		if (_shakeTime > 0)
		{
			var sx:Int = Std.random(_shakeMagnitude * 2 + 1) - _shakeMagnitude;
			var sy:Int = Std.random(_shakeMagnitude * 2 + 1) - _shakeMagnitude;

			x += sx - _shakeX;
			y += sy - _shakeY;

			_shakeX = sx;
			_shakeY = sy;

			_shakeTime -= HXP.elapsed;
			if (_shakeTime < 0) _shakeTime = 0;
		}
		else if (_shakeX != 0 || _shakeY != 0)
		{
			x -= _shakeX;
			y -= _shakeY;
			_shakeX = _shakeY = 0;
		}
	}

	var _shakeTime:Float=0;
	var _shakeMagnitude:Int=0;
	var _shakeX:Int=0;
	var _shakeY:Int=0;
}
