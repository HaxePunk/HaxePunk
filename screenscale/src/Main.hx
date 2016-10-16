import com.haxepunk.Engine;
import com.haxepunk.HXP;


class Main extends Engine
{

	override public function init()
	{
		HXP.console.enable();
		HXP.scene = new MainScene();
	}

	public static function main() { new Main(); }

}
