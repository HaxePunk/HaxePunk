package haxepunk.backend.lime;

class App extends haxepunk.backend.flash.FlashApiApp
{
	override public function initGamepadInput()
	{
		GamepadInput.init(this);
	}
}
