import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.Scene;

class TestScreen extends haxe.unit.TestCase
{

	public override function setup()
	{
		HXP.windowWidth = 320;
		HXP.windowHeight = 480;
		var engine = new Engine(HXP.windowWidth, HXP.windowHeight);
	}

	public function testDefaultSize()
	{
		assertEquals(320, HXP.width);
		assertEquals(480, HXP.height);
		assertEquals(1.0, HXP.screen.scale);
	}

	public function testScale()
	{
		HXP.screen.scale = 2;
		assertEquals(160, HXP.width);
		assertEquals(240, HXP.height);
		assertEquals(320, HXP.windowWidth);
		assertEquals(480, HXP.windowHeight);
	}

	public function testScaleXY()
	{
		HXP.screen.scaleX = 2;
		HXP.screen.scaleY = 3;
		assertEquals(160, HXP.width);
		assertEquals(160, HXP.height);
	}
}