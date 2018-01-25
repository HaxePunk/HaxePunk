package haxepunk;

class App extends haxepunk._internal.FlashApp
{
	override public function initGamepadInput()
	{
		haxepunk._internal.GamepadInput.init(this);
	}
}
