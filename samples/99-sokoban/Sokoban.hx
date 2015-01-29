import haxepunk.Engine;

class Sokoban extends Engine
{
	override public function ready()
	{
		scene.add(new Player());
	}
}
