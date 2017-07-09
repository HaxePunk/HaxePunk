import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;

class Main extends Engine
{

	override public function init()
	{
		Console.enable();
		add(new effects.GameScene());
	}

	public static function main() { new Main(); }

}