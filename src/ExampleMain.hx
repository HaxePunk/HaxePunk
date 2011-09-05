package ;

import flash.system.Capabilities;
import com.haxepunk.Engine;
import com.haxepunk.HXP;

class Main extends Engine 
{
	
	public static inline var kScreenWidth:Int = 800;
	public static inline var kScreenHeight:Int = 600;
	public static inline var kFrameRate:Int = 60;
	public static inline var kClearColor:Int = 0x000000;
	public static inline var kProjectName:String = "HaxePunk";
	
	public function new() 
	{
		super(kScreenWidth, kScreenHeight, kFrameRate, false);
	}
	
	override public function init()
	{
		if (Capabilities.isDebugger)
		{
			HXP.console.enable();
		}
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 1;
		HXP.world = new YourWorld();
	}
	
	static function main()
	{
#if flash
		new Main();
#else
		var flags = 
			   nme.Lib.RESIZABLE  |
			   nme.Lib.HARDWARE   |
			   nme.Lib.VSYNC      |
			   0;
		nme.Lib.create(function() { new Main(); }, kScreenWidth, kScreenHeight, kFrameRate, kClearColor, flags, kProjectName);
#end
	}
	
}