package haxepunk.screen;

import massive.munit.Assert;
import haxepunk.Engine;
import haxepunk.HXP;
import haxepunk.screen.UniformScaleMode;

class UniformScaleModeTest extends TestSuite
{
	var engine:Engine;

	@Before
	public function setup()
	{
		HXP.windowWidth = 320;
		HXP.windowHeight = 480;
		engine = new Engine(HXP.windowWidth, HXP.windowHeight);
	}

	@:access(haxepunk.Engine)
	function resize(width:Int, height:Int)
	{
		engine.resize(width, height);
		engine.update();
	}

	@Test
	public function testScale()
	{
		HXP.screen.scaleMode = new UniformScaleMode();

		resize(640, 960);
		Assert.areEqual(2, HXP.screen.fullScaleX);
		Assert.areEqual(2, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(640, HXP.windowWidth);
		Assert.areEqual(960, HXP.windowHeight);

		resize(320, 480);
		Assert.areEqual(1, HXP.screen.fullScaleX);
		Assert.areEqual(1, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(480, HXP.windowHeight);
	}

	@Test
	public function testScaleLetterbox()
	{
		HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Letterbox);

		resize(1280, 960);
		Assert.areEqual(2, HXP.screen.fullScaleX);
		Assert.areEqual(2, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(640, HXP.screen.width);
		Assert.areEqual(960, HXP.screen.height);
		Assert.areEqual(1280, HXP.windowWidth);
		Assert.areEqual(960, HXP.windowHeight);
		Assert.areEqual(320, HXP.screen.x);
		Assert.areEqual(0, HXP.screen.y);

		resize(320, 960);
		Assert.areEqual(1, HXP.screen.fullScaleX);
		Assert.areEqual(1, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(320, HXP.screen.width);
		Assert.areEqual(480, HXP.screen.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(960, HXP.windowHeight);
		Assert.areEqual(0, HXP.screen.x);
		Assert.areEqual(240, HXP.screen.y);

		resize(320, 480);
		Assert.areEqual(1, HXP.screen.fullScaleX);
		Assert.areEqual(1, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(320, HXP.screen.width);
		Assert.areEqual(480, HXP.screen.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(480, HXP.windowHeight);
		Assert.areEqual(0, HXP.screen.x);
		Assert.areEqual(0, HXP.screen.y);
	}

	@Test
	public function testScaleZoomIn()
	{
		HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.ZoomIn);

		resize(1280, 960);
		Assert.areEqual(4, HXP.screen.fullScaleX);
		Assert.areEqual(4, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(240, HXP.height);
		Assert.areEqual(1280, HXP.screen.width);
		Assert.areEqual(960, HXP.screen.height);
		Assert.areEqual(1280, HXP.windowWidth);
		Assert.areEqual(960, HXP.windowHeight);
		Assert.areEqual(0, HXP.screen.x);
		Assert.areEqual(0, HXP.screen.y);

		resize(320, 480);
		Assert.areEqual(1, HXP.screen.fullScaleX);
		Assert.areEqual(1, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(320, HXP.screen.width);
		Assert.areEqual(480, HXP.screen.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(480, HXP.windowHeight);
		Assert.areEqual(0, HXP.screen.x);
		Assert.areEqual(0, HXP.screen.y);
	}

	@Test
	public function testScaleExpand()
	{
		HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);

		resize(1280, 960);
		Assert.areEqual(2, HXP.screen.fullScaleX);
		Assert.areEqual(2, HXP.screen.fullScaleY);
		Assert.areEqual(640, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(1280, HXP.screen.width);
		Assert.areEqual(960, HXP.screen.height);
		Assert.areEqual(1280, HXP.windowWidth);
		Assert.areEqual(960, HXP.windowHeight);
		Assert.areEqual(0, HXP.screen.x);
		Assert.areEqual(0, HXP.screen.y);

		resize(320, 480);
		Assert.areEqual(1, HXP.screen.fullScaleX);
		Assert.areEqual(1, HXP.screen.fullScaleY);
		Assert.areEqual(320, HXP.width);
		Assert.areEqual(480, HXP.height);
		Assert.areEqual(320, HXP.screen.width);
		Assert.areEqual(480, HXP.screen.height);
		Assert.areEqual(320, HXP.windowWidth);
		Assert.areEqual(480, HXP.windowHeight);
		Assert.areEqual(0, HXP.screen.x);
		Assert.areEqual(0, HXP.screen.y);
	}
}
