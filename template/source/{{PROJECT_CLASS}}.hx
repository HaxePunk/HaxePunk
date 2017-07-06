import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.debug.Console;

class {{PROJECT_CLASS}} extends Engine
{
	override public function init()
	{
#if (debug || console)
		Console.enable();
#end
		HXP.scene = new MainScene();
	}
}
