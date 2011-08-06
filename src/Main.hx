import com.haxepunk.Engine;
import com.haxepunk.HXP;

class Main extends Engine
{
	
	public static inline var kScreenWidth:Int = 640;
	public static inline var kScreenHeight:Int = 480;
	public static inline var kFrameRate:Int = 60;
	public static inline var kClearColor:Int = 0xCCCCFF;
	public static inline var kProjectName:String = "HaxePunk";
	
	public function new()
	{
		super(kScreenWidth, kScreenHeight, kFrameRate, true);
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 1;
	}
	
	override public function init()
	{
		HXP.console.enable();
		// Place your code here
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