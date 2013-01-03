import com.haxepunk.Engine;
import com.haxepunk.HXP;

class {{PROJECT_CLASS}} extends Engine
{

	override public function init()
	{
#if debug
	#if flash
		if (flash.system.Capabilities.isDebugger)
	#end
		{
			HXP.console.enable();
		}
#end
		HXP.world = new YourWorld();
	}

}