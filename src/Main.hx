import com.haxepunk.Engine;
import com.haxepunk.HXP;

class Main extends Engine
{
	
	public function new()
	{
		super(640, 480, 60, true);
		HXP.console.enable();
	}
	
	static function main()
	{
		new Main();
	}
}