package com.matttuttle;

import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

/**
 * Example character class using simple physics
 */
class Character extends PhysicsEntity
{
	
	private var sprite:Spritemap;
	
	private static inline var kMoveSpeed:Int = 2;
	private static inline var kJumpForce:Int = 20;
	
	public function new(x:Float, y:Float)
	{
		super(x, y);
		
		sprite = new Spritemap(Assets.GfxCharacter, 32, 32);
		sprite.add("right_idle", [19, 19, 19, 20], 0.1, true);
		sprite.add("right_walk", [0, 1, 2, 3, 4, 5, 6, 7], 0.25, true);
		sprite.add("right_jump", [21]);
		
		sprite.add("left_idle", [17, 17, 17, 16], 0.1, true);
		sprite.add("left_walk", [15, 14, 13, 12, 11, 10, 9, 8], 0.25, true);
		sprite.add("left_jump", [18]);

		graphic = sprite;
		setHitbox(32, 32);

		// Set physics properties
		gravity.y = 2.6;
		maxVelocity.y = kJumpForce;
		maxVelocity.x = kMoveSpeed * 2;
		friction.x = 0.7;
		
		// Define input keys
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("jump", [Key.W, Key.SPACE, Key.UP]);
	}
	
	override public function update()
	{
		acceleration.x = acceleration.y = 0;
		
		if (Input.check("left"))
			acceleration.x = -kMoveSpeed;
		
		if (Input.check("right"))
			acceleration.x = kMoveSpeed;
		
		if (Input.pressed("jump") && onGround)
			acceleration.y = -kJumpForce;
		
		// Make animation changes here
		setAnimation();
		
		super.update();
	}
	
	private function setAnimation()
	{
		var animation:String;
		
		switch(facing)
		{
			case LEFT:
				animation = "left_";
			case RIGHT:
				animation = "right_";
			default:
				throw "Invalid direction";
		}
		
		if (onGround)
		{
			if (velocity.x == 0)
				animation += "idle";
			else
				animation += "walk";
		}
		else
		{
			animation += "jump";
		}
		
		sprite.play(animation);
	}
	
}