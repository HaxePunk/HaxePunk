package haxepunk;

import openfl.geom.Point;

/**
 * @since 4.0.0
 */
class Camera extends Point
{
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
			x = tx - (HXP.width * anchorX);
			y = ty - (HXP.height * anchorY);
		}
	}
}
