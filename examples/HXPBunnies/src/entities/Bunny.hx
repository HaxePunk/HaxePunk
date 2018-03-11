package entities;

import haxepunk.Entity;
import haxepunk.HXP;
import haxepunk.graphics.Image;
import haxepunk.Graphic;
import flash.geom.Point;

/**
 * ...
 * @author Zaphod
 */
class BunnyImage extends Image
{
	public var velocity:Point;
	public var angularVelocity:Float;

	public function new(graphic:ImageType)
	{
		super(graphic);

		velocity = new Point();
		angularVelocity = 0;

		maxX = HXP.width;
		maxY = HXP.height;
		active = true;
	}

	override public function update()
	{
		var elapsed = HXP.elapsed;
		x += velocity.x * elapsed;
		velocity.y = gravity * elapsed;
		y += velocity.y * elapsed;
		angle += angularVelocity * elapsed;
		alpha = 0.3 + 0.7 * y / maxY;

		if (x > maxX)
		{
			velocity.x *= -1;
			x = maxX;
		}
		else if (x < 0)
		{
			velocity.x *= -1;
			x = 0;
		}
		if (y > maxY)
		{
			velocity.y *= -0.8;
			y = maxY;
			if (Math.random() > 0.5) velocity.y -= 3 + Math.random() * 4;
		}
		else if (y < 0)
		{
			velocity.y *= -0.8;
			y = 0;
		}

		super.update();
	}

	static var maxX:Int = 320;
	static var maxY:Int = 480;
	static inline var gravity:Int = 5;

}