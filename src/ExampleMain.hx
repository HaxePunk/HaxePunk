package ;

import flash.system.Capabilities;
import com.haxepunk.Engine;
import com.haxepunk.HXP;

class ExampleMain extends Engine
{

	public static inline var kScreenWidth:Int = 640;
	public static inline var kScreenHeight:Int = 480;
	public static inline var kFrameRate:Int = 30;
	public static inline var kClearColor:Int = 0x333333;
	public static inline var kProjectName:String = "HaxePunk";

	public function new()
	{
		super(kScreenWidth, kScreenHeight, kFrameRate, false);
	}

	override public function init()
	{
#if flash
		if (Capabilities.isDebugger)
#end
		{
			HXP.console.enable();
		}
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 1;
//		HXP.world = new YourWorld();
	}

	public static function main()
	{
		new ExampleMain();
	}

}