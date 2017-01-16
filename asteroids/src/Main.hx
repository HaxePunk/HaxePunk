import haxepunk.Engine;
import haxepunk.HXP;


class Main extends Engine
{

	override public function init()
	{
		HXP.console.enable();
		HXP.scene = new MainScene();
	}

	public static function main() { new Main(); }

}
