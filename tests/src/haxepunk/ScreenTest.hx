package haxepunk;

import massive.munit.Assert;
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
		Assert.areEqual(1.0, HXP.screen.scale);
	}

	@Test
	public function testScale()
	{
		HXP.screen.scale = 2;
		HXP.resize(HXP.windowWidth, HXP.windowHeight);
		Assert.areEqual(160, HXP.width);
		Assert.areEqual(240, HXP.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(480, HXP.windowHeight);

		HXP.screen.scale = 1;
		HXP.resize(HXP.windowWidth, HXP.windowHeight);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(480, HXP.windowHeight);
	}

	@Test
	public function testScaleXY()
	{
		HXP.screen.scaleX = 2;
		HXP.screen.scaleY = 3;
		HXP.resize(HXP.windowWidth, HXP.windowHeight);
		Assert.areEqual(160, HXP.width);
		Assert.areEqual(160, HXP.height);

		HXP.screen.scaleX = 1;
		HXP.screen.scaleY = 1;
		HXP.resize(HXP.windowWidth, HXP.windowHeight);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
	}
}
