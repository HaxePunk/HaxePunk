package haxepunk.inputs;

@:access(haxepunk.inputs.Keyboard)
class KeyboardTest extends haxe.unit.TestCase
{

	public function testKeyDown()
	{
		Keyboard.onKeyDown(Keyboard.Key.LEFT, 0);
		assertTrue(Input.check(Keyboard.Key.LEFT));
	}

	public function testKeyUp()
	{
		for (key in Keyboard.Key.A...Keyboard.Key.Z)
		{
			var k:Keyboard.Key = cast key;
			Keyboard.onKeyUp(k, 0);
			assertEquals(1, Input.released(k));
		}
	}

	public function testDefine()
	{
		Input.define("jump", [Keyboard.Key.SPACE, Keyboard.Key.UP]);
		Keyboard.onKeyDown(Keyboard.Key.SPACE, 0);
		assertTrue(Input.check("jump"));
	}

}
