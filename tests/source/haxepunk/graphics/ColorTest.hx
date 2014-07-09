package haxepunk.graphics;

import haxepunk.math.Math;

class ColorTest extends haxe.unit.TestCase
{

	public function testHexCode()
	{
		var color = new Color(0.117, 0.53, 0.117, 0.95);
		assertEquals("#1D871D", color.toHexCode());
		assertEquals("#1D871DF2", color.toHexCode(true));
	}

	public function testInt()
	{
		var color = new Color(0.117, 0.53, 0.117, 0.95);
		assertEquals(0x1D871D, color.toInt());
		assertEquals(0x1D871DF2, color.toInt(true));
	}

	public function testHue()
	{
		var color = new Color(0.3, 0.4, 0.8, 1.0);
		assertEquals(0.63333, Math.roundTo(color.h, 5));
		assertEquals(0.6328125, Color.getColorHue(color.toInt()));
	}

	public function testSaturation()
	{
		var color = new Color(0.4, 0.4, 0.8, 1.0);
		assertEquals(0.5, color.s);
		assertEquals(0.5, Color.getColorSaturation(color.toInt()));
	}

	public function testValue()
	{
		var color = new Color(0.4, 0.4, 0.8, 1.0);
		assertEquals(0.8, color.v);
		assertEquals(0.8, Color.getColorValue(color.toInt()));
	}

}
