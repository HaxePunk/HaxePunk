package haxepunk.backend.lime;

import haxepunk.graphics.hardware.Texture;
import lime.graphics.opengl.GL;

class App extends haxepunk.backend.flash.FlashApiApp
{
	override public function initGamepadInput()
	{
		GamepadInput.init(this);
	}
}
