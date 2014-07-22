package haxepunk.graphics;

import haxepunk.graphics.Material;

class MaterialTest extends haxe.unit.TestCase
{

	public function testString()
	{
		var material = Material.fromText("material walls/funkywall1 { technique { pass { ambient 0.1 1.0 0.5 diffuse 0.5 0.3 0.2 depth_check false } } }");
		assertEquals("walls/funkywall1", material.name);
		assertEquals(1, material.techniques.length);
		assertEquals(1, material.techniques[0].passes.length);
		assertEquals(0.5, material.techniques[0].passes[0].ambient.b);
	}
}
