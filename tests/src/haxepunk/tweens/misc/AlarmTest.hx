package haxepunk.tweens.misc;

import massive.munit.Assert;

class AlarmTest extends TestSuite
{
	@Test
	public function testReset()
	{
		var alarm = new Alarm(1);
		Assert.areEqual(1, alarm.duration);
		Assert.isFalse(alarm.active);
		alarm.reset(3);
		Assert.areEqual(3, alarm.duration);
		Assert.isTrue(alarm.active);
	}

	@Test
	public function testProperties()
	{
		var alarm = new Alarm(2);
		alarm.start();
		alarm.update(1.5);
		Assert.areEqual(1.5, alarm.elapsed);
		Assert.areEqual(0.5, alarm.remaining);
	}
}
