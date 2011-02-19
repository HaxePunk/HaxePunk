import com.haxepunk.Engine;
import com.haxepunk.HXP;

import com.matttuttle.GameWorld;

class Main extends Engine
{
	
	public function new()
	{
		super(640, 480, 30, true);
		HXP.console.enable();
		HXP.world = new GameWorld();
	}
	
	static function main()
	{
		new Main();
	}
}