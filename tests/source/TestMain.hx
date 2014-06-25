class TestMain
{

	public static function main()
	{
		var runner = new haxe.unit.TestRunner();

		runner.add(new haxepunk.scene.SceneTest());

		// math tests
		runner.add(new haxepunk.math.MathTest());
		runner.add(new haxepunk.math.Matrix3DTest());
		runner.add(new haxepunk.math.Vector3DTest());

		// input tests
		runner.add(new haxepunk.input.MouseTest());

		// mask tests
		runner.add(new haxepunk.masks.AABBTest());

		runner.run();
	}

}
