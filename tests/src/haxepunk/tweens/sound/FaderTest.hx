package haxepunk.tweens.sound;

class FaderTest extends TestSuite
{
	@Test
	public function testFade()
	{
		var tween = new Fader();
		tween.fadeTo(0.2, 2);
		tween.update(1);
		Assert.areEqual(0.6, HXP.volume);
	}

	@Test
	public function testFadePastMax()
	{
		var tween = new Fader();
		HXP.volume = 0;
		tween.fadeTo(50, 2);
		tween.update(1);
		Assert.areEqual(1, HXP.volume);
	}

	@Test
	public function testFadePastMin()
	{
		var tween = new Fader();
		tween.fadeTo(-10, 2);
		tween.update(2);
		Assert.areEqual(0, HXP.volume);
	}
}
