package platformer.entities;

import flash.geom.Point;
import com.haxepunk.HXP;
import com.haxepunk.Entity;

class Physics extends Entity
{

	// Define variables
	public var velocity:Point;
	public var acceleration:Point;
	public var friction:Point;
	public var maxVelocity:Point;
	public var gravity:Point;

	public static var solid:String = "solid";

	public function new(x:Float, y:Float)
	{
		super(x, y);
		_onGround = _onWall = false;

		velocity     = new Point();
		acceleration = new Point();
		friction     = new Point();
		maxVelocity  = new Point();
		gravity      = new Point();
	}

	public var onGround(getOnGround, null): Bool;
	private function getOnGround():Bool { return _onGround; }

	public var onWall(getOnWall, null): Bool;
	private function getOnWall():Bool { return _onWall; }

	override public function update()
	{
		// Apply acceleration and velocity
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		applyVelocity();
		applyGravity();
		checkMaxVelocity();
		applyFriction();
		super.update();
	}

	public function applyGravity()
	{
		//increase velocity based on gravity
		velocity.x += gravity.x;
		velocity.y += gravity.y;
	}

	private function checkMaxVelocity()
	{
		if (maxVelocity.x > 0 && Math.abs(velocity.x) > maxVelocity.x)
		{
			velocity.x = maxVelocity.x * HXP.sign(velocity.x);
		}

		if (maxVelocity.y > 0 && Math.abs(velocity.y) > maxVelocity.y)
		{
			velocity.y = maxVelocity.y * HXP.sign(velocity.y);
		}
	}

	private function applyFriction()
	{
		// If we're on the ground, apply friction
		if (onGround && friction.x != 0)
		{
			if (velocity.x > 0)
			{
				velocity.x -= friction.x;
				if (velocity.x < 0)
				{
					velocity.x = 0;
				}
			}
			else if (velocity.x < 0)
			{
				velocity.x += friction.x;
				if (velocity.x > 0)
				{
					velocity.x = 0;
				}
			}
		}

		// Apply friction if on a wall
		if (onWall && friction.y != 0)
		{
			if (velocity.y > 0)
			{
				velocity.y -= friction.y;
				if (velocity.y < 0)
				{
					velocity.y = 0;
				}
			}
			else if (velocity.y < 0)
			{
				velocity.y += friction.y;
				if (velocity.y > 0)
				{
					velocity.y = 0;
				}
			}
		}
	}

	private function applyVelocity()
	{
		var i:Int;

		_onGround = false;
		_onWall = false;

		for (i in 0...Math.floor(Math.abs(velocity.x)))
		{
			if (collide(solid, x + HXP.sign(velocity.x), y) != null)
			{
				_onWall = true;
				velocity.x = 0;
				break;
			}
			else
			{
				x += HXP.sign(velocity.x);
			}
		}

		for (i in 0...Math.floor(Math.abs(velocity.y)))
		{
			if (collide(solid, x, y + HXP.sign(velocity.y)) != null)
			{
				if (HXP.sign(velocity.y) == HXP.sign(gravity.y))
					_onGround = true;
				velocity.y = 0;
				break;
			}
			else
			{
				y += HXP.sign(velocity.y);
			}
		}
	}

	private var _onGround:Bool;
	private var _onWall:Bool;

}
