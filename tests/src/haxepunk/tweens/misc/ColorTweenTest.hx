package haxepunk.tweens.misc;

class ColorTweenTest extends TestSuite
{
	@Test
	public function testUpdate()
	{
		var tween = new ColorTween();
		tween.tween(2, 0xFFFFFF, 0xac00FF, 1, 0.5);
		tween.update(1);
		Assert.areEqual(0xD5, tween.red);
		Assert.areEqual(0x7F, tween.green);
		Assert.areEqual(0xFF, tween.blue);
		Assert.areEqual(0.75, tween.alpha);
		Assert.areEqual(0xD57FFF, tween.color);
	}
}
