class TestMain
{

	public static function main()
	{
		var runner = new haxe.unit.TestRunner();

		// graphic tests
		// runner.add(new haxepunk.graphics.ColorTest());
		// runner.add(new haxepunk.graphics.ImageTest());
		// runner.add(new haxepunk.graphics.MaterialTest());
		// runner.add(new haxepunk.graphics.TextureAtlasTest());
		// runner.add(new haxepunk.graphics.TilemapTest());

		// scene tests
		runner.add(new haxepunk.scene.EntityTest());
		runner.add(new haxepunk.scene.SceneTest());

		// math tests
		runner.add(new haxepunk.math.MathTest());
		runner.add(new haxepunk.math.Matrix4Test());
		runner.add(new haxepunk.math.RectangleTest());
		runner.add(new haxepunk.math.Vector3Test());

		// input tests
		runner.add(new haxepunk.inputs.KeyboardTest());
		runner.add(new haxepunk.inputs.MouseTest());

		// mask tests
		runner.add(new haxepunk.masks.AABBTest());
		runner.add(new haxepunk.masks.SphereTest());

		runner.run();
	}

}
