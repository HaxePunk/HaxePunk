package haxepunk.input;

@:access(haxepunk.input.Input)
@:access(haxepunk.input.Mouse)
class MouseTest extends haxe.unit.TestCase
{

	override public function setup()
	{
		// reset mouse values
		for (state in Mouse._states)
		{
			state.on = state.pressed = state.released = 0;
		}
	}

	public function testCheck()
	{
		Input.define("left", [Mouse.MouseButton.Left]);
		Input.define("right", [Mouse.MouseButton.Right]);
		Input.define("all", [Mouse.MouseButton.Any]);
		Input.define("both", [Mouse.MouseButton.Left, Mouse.MouseButton.Right]);

		assertFalse(Input.check("left"));
		assertFalse(Input.check("right"));

		// undefined but should return false instead of throwing an error
		assertFalse(Input.check("foo"));

		Mouse.onMouseDown(0, 0, Mouse.MouseButton.Left);
		assertTrue(Input.check("left"));
		assertTrue(Input.check("all"));

		Mouse.onMouseDown(0, 0, Mouse.MouseButton.Right);
		assertTrue(Input.check("right"));
		assertTrue(Input.check("all"));
		assertTrue(Input.check("both"));

		Input.update();

		Mouse.onMouseUp(0, 0, Mouse.MouseButton.Left);

		assertTrue(Input.check("left")); // left is still "on" but not "pressed"

		Input.update();

		assertFalse(Input.check("left"));
		assertTrue(Input.check("all"));
	}

	public function testMousePressed()
	{
		assertEquals(0, Input.pressed(Mouse.MouseButton.Left));

		Mouse.onMouseDown(0, 0, Mouse.MouseButton.Left);
		assertEquals(1, Input.pressed(Mouse.MouseButton.Left));

		Mouse.onMouseDown(0, 0, Mouse.MouseButton.Left);
		assertEquals(0, Input.released(Mouse.MouseButton.Left));
		assertEquals(2, Input.pressed(Mouse.MouseButton.Left));

		Mouse.onMouseUp(0, 0, Mouse.MouseButton.Left);
		assertEquals(1, Input.released(Mouse.MouseButton.Left));

		Input.update();
		assertEquals(0, Input.pressed(Mouse.MouseButton.Left));
	}

	public function testMousePosition()
	{
		Mouse.onMouseDown(10, 45, Mouse.MouseButton.Left);
		assertEquals(10.0, Mouse.x);
		assertEquals(45.0, Mouse.y);
	}

	public function testMouseWheel()
	{
		Mouse.onMouseWheel(1, 2);
		assertEquals(1.0, Mouse.wheelDelta);
	}

}
