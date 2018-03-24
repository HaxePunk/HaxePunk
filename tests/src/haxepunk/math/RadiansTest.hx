package haxepunk.math;

class RadiansTest
{
	@Test
	public function testConversion()
	{
		var d:Degrees = 180;
		var r:Radians = d;

		Assert.areEqual(d.toRadians(), r);
		Assert.areEqual(r, -Math.PI);
		Assert.areEqual("180 deg", d.toString());
		Assert.areEqual("-1*PI", r.toString());
	}
}
