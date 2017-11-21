package haxepunk.backend.nme;

class App extends haxepunk.backend.flash.FlashApiApp
{
	override public function initGamepadInput()
	{
		GamepadInput.init(this);
	}
}
