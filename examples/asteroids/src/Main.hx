import haxepunk.Engine;
import haxepunk.HXP;


class Main extends Engine
{

	override public function init()
	{
		haxepunk.debug.Console.enabled = true;
		HXP.scene = new MainScene();
	}

	public static function main() { new Main(); }

}
