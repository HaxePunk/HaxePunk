package haxepunk.input;

import haxepunk.input.gamepad.GamepadType;
import haxepunk.input.gamepad.GamepadButton;

class GamepadTest extends TestSuite
{
	@Test
	public function testControllerMapping()
	{
		// PS3 controller
		var GUID = "030000004c0500006802000010010000";
		var ctrl = GamepadType.get(GUID);
		Assert.isNotNull(ctrl);
		Assert.areEqual(GamepadButton.LeftShoulder, ctrl.mapButton(10));
	}
}
