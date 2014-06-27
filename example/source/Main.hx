import haxepunk.Engine;

class Main extends Engine
{
	override public function ready()
	{
		scene.add(new Player());
	}
}
