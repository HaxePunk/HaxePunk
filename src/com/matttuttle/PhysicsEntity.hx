package com.matttuttle;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import flash.geom.Point;

enum Direction
{
	LEFT;
	RIGHT;
	UP;
	DOWN;
}

class PhysicsEntity extends Entity
{
	
	// Define variables
	public var velocity:Point;
	public var acceleration:Point;
	public var friction:Point;
	public var maxVelocity:Point;
	public var gravity:Point;
	
	public var onGround:Bool;
	public var facing:Direction;
	public var solid:String;
	
	public function new(x:Float, y:Float)
	{
		super(x, y);
		velocity      = new Point(0, 0);
		acceleration  = new Point(0, 0);
		friction      = new Point(0, 0);
		maxVelocity   = new Point(0, 0);
		gravity       = new Point(0, 0);
		
		onGround = false;
		facing = RIGHT;
		solid = "solid";
	}
	
	override public function update()
	{
		applyAcceleration();
		applyVelocity();
		
		onGround = false;
		if (collide(solid, x, y + 1) != null)
			onGround = true;
		
		applyGravity();
		applyFriction();
		checkMaxVelocity();
		
		// Always face the direction we were last heading
		if (velocity.x < 0)
			facing = Direction.LEFT;
		else if (velocity.x > 0)
			facing = Direction.RIGHT;
		
		super.update();
	}
	
	public function applyGravity()
	{
		//increase velocity based on gravity
		velocity.x += gravity.x;
		velocity.y += gravity.y;
	}
	
	private function applyAcceleration()
	{
		// X-Axis
		if (acceleration.x != 0)
		{
			velocity.x += acceleration.x;
		}
		
		// Y-Axis
		if (acceleration.y != 0)
		{
			velocity.y += acceleration.y;
		}
	}
	
	private function checkMaxVelocity()
	{
		if (maxVelocity.x != 0)
		{
			if (Math.abs(velocity.x) > maxVelocity.x)
			{
				velocity.x = maxVelocity.x * HXP.sign(velocity.x);
			}
		}
		
		if (maxVelocity.y != 0)
		{
			if (Math.abs(velocity.y) > maxVelocity.y)
			{
				velocity.y = maxVelocity.y * HXP.sign(velocity.y);
			}
		}
	}
	
	private function applyFriction()
	{
		// If we're on the ground, apply friction
		if (onGround)
		{
			if (velocity.x > 0)
			{
				velocity.x -= friction.x;
				if (velocity.x < 0)
				{
					velocity.x = 0;
				}
			}
			if (velocity.x < 0)
			{
				velocity.x += friction.x;
				if (velocity.x > 0)
				{
					velocity.x = 0;
				}
			}
		}
	}
	
	private function applyVelocity()
	{
		var i:Int;
		
		for (i in 0...Std.int(Math.abs(velocity.x)))
		{
			if (collide(solid, x + HXP.sign(velocity.x), y) != null)
			{
				velocity.x = 0;
				break;
			}
			else
			{
				x += HXP.sign(velocity.x);
			}
		}
		
		for (i in 0...Std.int(Math.abs(velocity.y)))
		{
			if (collide(solid, x, y + HXP.sign(velocity.y)) != null)
			{
				velocity.y = 0;
				break;
			}
			else
			{
				y += HXP.sign(velocity.y);
			}
		}
	}
	
}