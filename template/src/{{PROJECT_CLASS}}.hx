import com.haxepunk.Engine;
import com.haxepunk.HXP;

class {{PROJECT_CLASS}} extends Engine
{

	public static inline var kScreenWidth:Int = {{WIDTH}};
	public static inline var kScreenHeight:Int = {{HEIGHT}};
	public static inline var kFrameRate:Int = {{FRAMERATE}};
	public static inline var kClearColor:Int = 0x333333;
	public static inline var kProjectName:String = "{{PROJECT_NAME}}";

	public function new()
	{
		super(kScreenWidth, kScreenHeight, kFrameRate, false);
	}

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
		HXP.screen.color = kClearColor;
//		HXP.world = new YourWorld();
	}

	public static function main()
	{
		new {{PROJECT_CLASS}}();
	}

}