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
		overlayText.scrollX = overlayText.scrollY = 0;
		var overlay:Entity = new Entity(0, HXP.screen.height - 20, overlayText);
		overlay.layer = 0;
		add(overlay);

		var c = Type.getClassName(Type.getClass(this));
		for (i in 0..._worlds.length)
		{
			if (_worlds[i] == c)
			{
				_currentWorld = i;
				break;
			}
		}

		tapTime = 0;
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

	private inline function nextWorld()
	{
		_currentWorld -= 1;
		if (_currentWorld < 0)
			_currentWorld = _worlds.length - 1;

		loadWorld();
	}

	private inline function previousWorld()
	{
		_currentWorld += 1;
		if (_currentWorld > _worlds.length - 1)
			_currentWorld = 0;

		loadWorld();
	}

	public override function update()
	{
		tapTime -= HXP.elapsed;
		if (Input.mousePressed)
		{
			if (tapTime > 0)
			{
				nextWorld();
			}
			tapTime = 0.6;
		}

		// cycle through worlds with '[' and ']'
		if (Input.pressed(Key.LEFT_SQUARE_BRACKET))
		{
			nextWorld();
		}
		if (Input.pressed(Key.RIGHT_SQUARE_BRACKET))
		{
			previousWorld();
		}
		super.update();
	}

	private var overlayText:Text;
	private var tapTime:Float;

	private static var _currentWorld:Int = 0;
	private static var _worlds:Array<String> = [
		'masks.GameWorld',
		'effects.GameWorld',
		'platformer.GameWorld'
	];

}