import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.Entity;
import haxepunk.graphics.Text;
import haxepunk.input.Input;
import haxepunk.input.Key;

// have to import scenes for compilation
import platformer.GameScene;
import masks.GameScene;
import masks.SlopedScene;
import effects.GameScene;
import layers.LayerScene;

class DemoScene extends Scene
{

	public function new()
	{
		super();

		overlayText = new Text("Press '[' and ']' to switch demos", 0, 0);
		overlayText.resizable = true;
		overlayText.scrollX = overlayText.scrollY = 0;
		var overlay:Entity = new Entity(0, HXP.screen.height - 20, overlayText);
		overlay.layer = -10;
		add(overlay);

		var c = Type.getClassName(Type.getClass(this));
		for (i in 0..._scenes.length)
		{
			if (_scenes[i] == c)
			{
				_currentScene = i;
				break;
			}
		}

		tapTime = 0;
	}

	private function loadScene():Bool
	{
		var classDef = Type.resolveClass(_scenes[_currentScene]);
		if (classDef == null) return false;

		var scene = Type.createInstance(classDef, []);
		if (scene == null) return false;

		HXP.scene = scene;
		return true;
	}

	private inline function nextScene()
	{
		_currentScene -= 1;
		if (_currentScene < 0)
			_currentScene = _scenes.length - 1;

		loadScene();
	}

	private inline function previousScene()
	{
		_currentScene += 1;
		if (_currentScene > _scenes.length - 1)
			_currentScene = 0;

		loadScene();
	}

	public override function update()
	{
		tapTime -= HXP.elapsed;
		if (Input.mousePressed)
		{
			if (tapTime > 0)
			{
				nextScene();
			}
			tapTime = 0.6;
		}

		// cycle through scenes with '[' and ']'
		if (Input.pressed(Key.LEFT_SQUARE_BRACKET))
		{
			nextScene();
		}
		if (Input.pressed(Key.RIGHT_SQUARE_BRACKET))
		{
			previousScene();
		}
		if (Input.pressed(Key.F))
		{
			HXP.fullscreen = !HXP.fullscreen;
		}
		super.update();
	}

	private var overlayText:Text;
	private var tapTime:Float;

	private static var _currentScene:Int = 0;
	private static var _scenes:Array<String> = [
		'masks.GameScene',
		'masks.SlopedScene',
		'effects.GameScene',
		'platformer.GameScene',
		'layers.LayerScene'
	];

}