import haxepunk.Engine;
import haxepunk.debug.Console;

class Main extends Engine
{

	override public function init()
	{
		Console.enable();
		setScene(new MainScene());
	}

}
