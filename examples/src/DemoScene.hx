import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

// have to import scenes for compilation
import platformer.GameScene;
import masks.GameScene;
import effects.GameScene;

class DemoScene extends Scene
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
		'effects.GameScene',
		'platformer.GameScene'
	];

}