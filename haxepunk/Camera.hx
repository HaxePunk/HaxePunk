package haxepunk;

/**
 * @since 4.0.0
 */
class Camera
{
	public var x:Float;
	public var y:Float;

	public var scale:Float = 1;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	public function new(x:Float = 0, y:Float = 0)
	{
		setTo(x, y);
	}

	public inline function setTo(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
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
	inline function get_screenScaleX() return fullScaleX * HXP.screen.fullScaleX;
	public var screenScaleY(get, never):Float;
	inline function get_screenScaleY() return fullScaleY * HXP.screen.fullScaleY;

	public var width(get, never):Float;
	inline function get_width() return HXP.screen.width / screenScaleX;

	public var height(get, never):Float;
	inline function get_height() return HXP.screen.height / screenScaleY;

	/**
	 * Return an X value that, after scaling, will result in an integer.
	 */
	public inline function floorX(x:Float) return Math.floor(x * screenScaleX) / screenScaleX;
	/**
	 * Return a Y value that, after scaling, will result in an integer.
	 */
	public inline function floorY(y:Float) return Math.floor(y * screenScaleY) / screenScaleY;

	var anchorTarget:Null<Position>;
	var anchorX:Float = 0;
	var anchorY:Float = 0;

	/**
	 * Anchor the Camera to an Entity or other object with position. The
	 * Camera will keep the target in the specified part of the screen.
	 * @since 4.0.0
	 */
	public function anchor(?target:Position, anchorX:Float = 0.5, anchorY:Float = 0.5)
	{
		anchorTarget = target;
		this.anchorX = anchorX;
		this.anchorY = anchorY;
	}

	public function onCamera(entity:Entity):Bool
	{
		return entity.collideRect(entity.x, entity.y, x, y, HXP.width, HXP.height);
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
				tx += e.width / 2;
				ty += e.height / 2;
			}
			x = tx - (HXP.width / fullScaleX * anchorX);
			y = ty - (HXP.height / fullScaleY * anchorY);
		}
	}
}
