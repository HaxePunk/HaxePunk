package haxepunk;

import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.Scene;

class ScreenTest extends TestSuite
{
	@Before
	public function setup()
	{
		HXP.windowWidth = 320;
		HXP.windowHeight = 480;
		HXP.engine = new Engine(HXP.windowWidth, HXP.windowHeight);
		HXP.screen.scaleMode.setBaseSize();
	}

	@Test
	public function testDefaultSize()
	{
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(1.0, HXP.screen.scaleX);
		Assert.areEqual(1.0, HXP.screen.scaleY);
	}
}
