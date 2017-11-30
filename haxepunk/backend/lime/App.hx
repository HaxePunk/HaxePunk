package haxepunk.backend.lime;

#if lime

class App extends haxepunk.backend.flash.FlashApiApp
{
	override public function initGamepadInput()
	{
		GamepadInput.init(this);
	}
}

#end
