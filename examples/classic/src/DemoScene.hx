import haxepunk.HXP;
import haxepunk.Scene;
import haxepunk.Entity;
import haxepunk.graphics.text.Text;
import haxepunk.input.Input;
import haxepunk.input.Key;
import haxepunk.input.Mouse;

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

		Key.define("next_scene", [Key.LEFT_SQUARE_BRACKET]);
		Key.define("prev_scene", [Key.RIGHT_SQUARE_BRACKET]);
		Key.define("fullscreen", [Key.F]);
		onInputPressed.next_scene.bind(nextScene);
		onInputPressed.prev_scene.bind(previousScene);
		onInputPressed.fullscreen.bind(function() HXP.fullscreen = !HXP.fullscreen);
	}

	function loadScene():Bool
	{
		var classDef = Type.resolveClass(_scenes[_currentScene]);
		if (classDef == null) return false;

		var scene = Type.createInstance(classDef, []);
		if (scene == null) return false;

		HXP.scene = scene;
		return true;
	}

	inline function nextScene()
	{
		_currentScene -= 1;
		if (_currentScene < 0)
			_currentScene = _scenes.length - 1;

		loadScene();
	}

	inline function previousScene()
	{
		_currentScene += 1;
		if (_currentScene > _scenes.length - 1)
			_currentScene = 0;

		loadScene();
	}

	public override function update()
	{
		tapTime -= HXP.elapsed;
		if (Mouse.mousePressed)
		{
			if (tapTime > 0)
			{
				nextScene();
			}
			tapTime = 0.6;
		}

		// cycle through scenes with '[' and ']'
		super.update();
	}

	var overlayText:Text;
	var tapTime:Float;

	static var _currentScene:Int = 0;
	static var _scenes:Array<String> = [
		'masks.GameScene',
		'masks.SlopedScene',
		'effects.GameScene',
		'platformer.GameScene',
		'layers.LayerScene'
	];

}