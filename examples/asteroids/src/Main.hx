import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;
import haxepunk.pixel.PixelArtScaler;

class Main extends Engine
{
	override public function init()
	{
		PixelArtScaler.baseWidth = Std.int(HXP.width / 2);
		PixelArtScaler.baseHeight = Std.int(HXP.height / 2);
		Console.enable();
		HXP.scene = new asteroids.scenes.MainScene();
	}
}
