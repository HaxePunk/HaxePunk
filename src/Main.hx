import com.haxepunk.Engine;
import com.haxepunk.HXP;

import test.GameWorld;

class Main extends Engine
{
	
	public function new()
	{
		super(640, 480, 60, true);
		HXP.console.enable();
		HXP.world = new GameWorld();
	}
	
	static function main()
	{
		new Main();
	}
}