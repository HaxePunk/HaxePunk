package platformer.entities;

import haxepunk.HXP;
import haxepunk.Sfx;
import haxepunk.graphics.Spritemap;
import haxepunk.input.Input;
import haxepunk.input.Gamepad;
import haxepunk.input.gamepads.XboxGamepad;
import haxepunk.input.Key;
import haxepunk.input.Mouse;
import haxepunk.math.MathUtil;
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
		sprite.centerOrigin();
		setHitbox(16, 32, 8, 16);

		// Set physics properties
		gravity.y = 1.8;
		maxVelocity.y = kJumpForce;
		maxVelocity.x = kMoveSpeed * 4;
		friction.x = 0.82; // floor friction
		friction.y = 0.99; // wall friction

		// Define input keys
		Key.define("left", [Key.A, Key.LEFT]);
		Key.define("right", [Key.D, Key.RIGHT]);
		Key.define("jump", [Key.W, Key.SPACE, Key.UP]);
		Key.define("switch_jump_mode", [Key.J]);

		Mouse.define("switch_jump_mode", MouseButton.RIGHT);

		Gamepad.onConnect.bind(registerGamepad);
		for (gamepad in Gamepad.gamepads) registerGamepad(gamepad);
	}

	override public function added()
	{
		scene.onInputPressed.switch_jump_mode.bind(switchJumpStyle);
	}

	function registerGamepad(gamepad:Gamepad)
	{
		gamepad.defineButton("left", [XboxGamepad.DPAD_LEFT]);
		gamepad.defineButton("right", [XboxGamepad.DPAD_RIGHT]);
		gamepad.defineButton("jump", [XboxGamepad.A_BUTTON]);
		gamepad.defineButton("switch_jump_mode", [XboxGamepad.B_BUTTON]);
		gamepad.defineAxis("left", XboxGamepad.LEFT_ANALOGUE_X, -0.1, -1);
		gamepad.defineAxis("right", XboxGamepad.LEFT_ANALOGUE_X, 0.1, 1);
		gamepad.defineAxis("jump", XboxGamepad.LEFT_ANALOGUE_Y, -0.5, -1);
		gamepad.defineAxis("jump", XboxGamepad.RIGHT_ANALOGUE_Y, -0.5, -1);
	}

	function doJump()
	{
		if (!onGround) return;
		switch (jumpStyle)
		{
			case Normal:
				var sfx = new Sfx("sfx/jump.wav");
				sfx.play(0.8);
				acceleration.y = -MathUtil.sign(gravity.y) * kJumpForce;
			case Gravity:
				gravity.y = -gravity.y;
			case Disable:
		}
	}

	function switchJumpStyle()
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

		if (Mouse.mouseDown)
		{
			if (scene.mouseX < x)
				acceleration.x = -kMoveSpeed;
			if (scene.mouseX > x)
				acceleration.x = kMoveSpeed;
			if (scene.mouseY < y - 32)
				doJump();
		}

		if (Input.check("left"))
			acceleration.x = -kMoveSpeed;

		if (Input.check("right"))
			acceleration.x = kMoveSpeed;

		if (Input.pressed("jump"))
		{
			doJump();
		}

		// Make animation changes here
		setAnimation();

		super.update();

		// Always face the direction we were last heading
		if (velocity.x < 0)
		{
			sprite.flipX = true; // left
		}
		else if (velocity.x > 0)
		{
			sprite.flipX = false; // right
		}
	}

	function setAnimation()
	{
		var anim:String = "norm_";
		if (gravity.y < 0)
		{
			anim = "grav_";
		}

		if (onGround)
		{
			if (velocity.x == 0)
			{
				sprite.play(anim + "idle");
			}
			else
			{
				sprite.play(anim + "walk");
			}
		}
		else
		{
			sprite.play(anim + "jump");
		}
	}

	var sprite:Spritemap;

	static var jumpStyle:JumpStyle = Normal;
	static inline var kMoveSpeed:Float = 0.8;
	static inline var kJumpForce:Int = 20;

}
