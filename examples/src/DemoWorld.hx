import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

// have to import worlds for compilation
import platformer.GameWorld;
import masks.GameWorld;
import effects.GameWorld;

class DemoWorld extends World
{

	public function new()
	{
		super();

		overlayText = new Text("Press '[' and ']' to switch demos", 0, 0);
		overlayText.resizable = true;
		var overlay:Entity = new Entity(0, HXP.screen.height - 20, overlayText);
		overlay.layer = 0;
		add(overlay);
	}

	private function loadWorld():Bool
	{
		var classDef = Type.resolveClass(_worlds[_currentWorld]);
		if (classDef == null) return false;

		var world = Type.createInstance(classDef, []);
		if (world == null) return false;

		HXP.world = world;
		return true;
	}

	public override function update()
	{
		// cycle through worlds with '[' and ']'
		if (Input.pressed(Key.LEFT_SQUARE_BRACKET))
		{
			_currentWorld -= 1;
			if (_currentWorld < 0)
				_currentWorld = _worlds.length - 1;

			loadWorld();
		}
		if (Input.pressed(Key.RIGHT_SQUARE_BRACKET))
		{
			_currentWorld += 1;
			if (_currentWorld > _worlds.length - 1)
				_currentWorld = 0;

			loadWorld();
		}
		super.update();
	}

	private var overlayText:Text;

	private static var _currentWorld:Int = 0;
	private static var _worlds:Array<String> = [
		'effects.GameWorld',
		'masks.GameWorld',
		'platformer.GameWorld'
	];

}