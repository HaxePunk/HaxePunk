package platformer.entities;

import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import platformer.entities.Physics;

private enum JumpStyle
{
	Normal;
	Gravity;
	Disable;
}

// Example character class using simple physics
class Player extends Physics
{

	public function new(x:Float, y:Float)
	{
		super(x, y);

		sprite = new Spritemap("gfx/character.png", 32, 32);

		sprite.add("norm_idle", [8, 8, 8, 9], 3, true);
		sprite.add("norm_walk", [0, 1, 2, 3, 4, 5, 6, 7], 19, true);
		sprite.add("norm_jump", [10]);

		sprite.add("grav_idle", [19, 19, 19, 20], 2, true);
		sprite.add("grav_walk", [11, 12, 13, 14, 15, 16, 17, 18], 19, true);
		sprite.add("grav_jump", [21]);

		graphic = sprite;
		setHitbox(16, 32, -8);

		// Set physics properties
		gravity.y = 1.8;
		maxVelocity.y = kJumpForce;
		maxVelocity.x = kMoveSpeed * 4;
		friction.x = 0.82; // floor friction
		friction.y = 0.99; // wall friction

		// Define input keys
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("jump", [Key.W, Key.SPACE, Key.UP]);
	}

	private function doJump()
	{
		if (!onGround) return;
		switch (jumpStyle)
		{
			case Normal:
				acceleration.y = -HXP.sign(gravity.y) * kJumpForce;
			case Gravity:
				gravity.y = -gravity.y;
			case Disable:
		}
	}

	private function switchJumpStyle()
	{
		switch (jumpStyle)
		{
			case Normal:  jumpStyle = Gravity;
			case Gravity: jumpStyle = Normal;
			case Disable: trace('disabled');
		}
	}

	override public function update()
	{
		acceleration.x = acceleration.y = 0;

		var joystick = Input.joystick(1);
		if (joystick.connected)
		{
			acceleration.x = joystick.getAxis(1);

			if (joystick.pressed(1)) doJump();
			if (joystick.pressed(2)) switchJumpStyle();
		}

		if (Input.mouseDown)
		{
			if (world.mouseX < x)
				acceleration.x = -kMoveSpeed;
			if (world.mouseX > x)
				acceleration.x = kMoveSpeed;
			if (world.mouseY < y - 32)
				doJump();
		}

		if (Input.check("left"))
			acceleration.x = -kMoveSpeed;

		if (Input.check("right"))
			acceleration.x = kMoveSpeed;

		if (Input.pressed(Key.J))
		{
			switchJumpStyle();
		}

		if (Input.pressed("jump"))
		{
			doJump();
		}

		// Make animation changes here
		setAnimation();

		super.update();

		// Always face the direction we were last heading
		if (velocity.x < 0)
			sprite.flipped = true; // left
		else if (velocity.x > 0)
			sprite.flipped = false; // right
	}

	private function setAnimation()
	{
		var anim:String = "norm_";
		if (gravity.y < 0) {
			anim = "grav_";
		}

		if (onGround)
		{
			if (velocity.x == 0)
				sprite.play(anim + "idle");
			else
				sprite.play(anim + "walk");
		}
		else
		{
			sprite.play(anim + "jump");
		}
	}

	private var sprite:Spritemap;

	private static var jumpStyle:JumpStyle = Normal;
	private static inline var kMoveSpeed:Float = 0.8;
	private static inline var kJumpForce:Int = 20;

}
