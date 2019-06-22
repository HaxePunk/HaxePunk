import haxepunk.Engine;
import haxepunk.HXP;

class {{PROJECT_CLASS}} extends Engine
{
	static function main()
	{
		// TODO reflect {{FRAMERATE}} and {{WIDTH}}/{{HEIGHT}} in setup.
		new {{PROJECT_CLASS}}();
	}

	override public function init()
	{
		HXP.scene = new MainScene();
	}
}
