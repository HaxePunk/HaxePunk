package haxepunk.input;

typedef InputHandler =
{
	function update():Void;
	function postUpdate():Void;
	function checkInput(input:InputType):Bool;
	function pressedInput(input:InputType):Bool;
	function releasedInput(input:InputType):Bool;
}
