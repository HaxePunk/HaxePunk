package platformer.entities;

import flash.geom.Point;
import haxepunk.HXP;
import haxepunk.Entity;
import haxepunk.utils.MathUtil;

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
		_onGround = false;

		velocity     = new Point();
		acceleration = new Point();
		friction     = new Point();
		maxVelocity  = new Point();
		gravity      = new Point();
	}

	public var onGround(get_onGround, null): Bool;
	private function get_onGround():Bool { return _onGround; }

	override public function update()
	{
		// Apply acceleration and velocity
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		applyVelocity();
		applyGravity();
		checkMaxVelocity();
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
			velocity.x = maxVelocity.x * MathUtil.sign(velocity.x);
		}

		if (maxVelocity.y > 0 && Math.abs(velocity.y) > maxVelocity.y)
		{
			velocity.y = maxVelocity.y * MathUtil.sign(velocity.y);
		}
	}

	public override function moveCollideY(e:Entity):Bool
	{
		if (velocity.y * MathUtil.sign(gravity.y) > 0)
		{
			_onGround = true;
		}
		velocity.y = 0;

		velocity.x *= friction.x;
		if (Math.abs(velocity.x) < 0.5) velocity.x = 0;
		return true;
	}

	public override function moveCollideX(e:Entity):Bool
	{
		velocity.x = 0;

		velocity.y *= friction.y;
		if (Math.abs(velocity.y) < 1) velocity.y = 0;
		return true;
	}

	private function applyVelocity()
	{
		var i:Int;

		_onGround = false;

		moveBy(velocity.x, velocity.y, solid, true);
	}

	private var _onGround:Bool;

}
