package haxepunk.backend.nme;

#if nme

class App extends haxepunk.backend.flash.FlashApiApp
{
	override public function initGamepadInput()
	{
		GamepadInput.init(this);
	}
}

#end
