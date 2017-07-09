import haxepunk.Engine;
import haxepunk.HXP;
import openfl.display.FPS;
import flash.Lib;

class Main extends Engine
{

	override public function init()
	{
		add(new scenes.GameScene());

		var fps:FPS = new FPS(10, 10, 0);
		var format = fps.defaultTextFormat;
		format.size = 20;
		fps.defaultTextFormat = format;
		Lib.current.stage.addChild(fps);
	}

}