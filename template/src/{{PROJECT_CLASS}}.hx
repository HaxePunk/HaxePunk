import com.haxepunk.Engine;
import com.haxepunk.HXP;

class {{PROJECT_CLASS}} extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.scene = new MainScene();
	}

	public static function main() { new {{PROJECT_CLASS}}(); }

}