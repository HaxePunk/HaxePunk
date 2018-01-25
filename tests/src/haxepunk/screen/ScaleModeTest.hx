package haxepunk.screen;

import haxepunk.Engine;
import haxepunk.HXP;

class ScaleModeTest extends TestSuite
{
	@Before
	public function setup()
	{
		HXP.windowWidth = 320;
		HXP.windowHeight = 480;
		var engine = new Engine(HXP.windowWidth, HXP.windowHeight);
	}

	@Test
	public function testScale()
	{
		HXP.screen.scaleMode = new ScaleMode();
		HXP.resize(640, 960);
		Assert.areEqual(2, HXP.screen.scaleX);
		Assert.areEqual(2, HXP.screen.scaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(640, HXP.windowWidth);
		Assert.areEqual(960, HXP.windowHeight);

		HXP.screen.scaleMode = new ScaleMode();
		HXP.resize(960, 960);
		Assert.areEqual(3, HXP.screen.scaleX);
		Assert.areEqual(2, HXP.screen.scaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(960, HXP.windowWidth);
		Assert.areEqual(960, HXP.windowHeight);

		HXP.screen.scaleMode = new ScaleMode(true);
		HXP.resize(320, 480);
		Assert.areEqual(1, HXP.screen.scaleX);
		Assert.areEqual(1, HXP.screen.scaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(480, HXP.windowHeight);
	}
}
