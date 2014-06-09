class TestMain
{

	public static function main()
	{
		var runner = new haxe.unit.TestRunner();
		runner.add(new SceneTest());
		runner.add(new MatrixTest());
		runner.run();
	}

}
