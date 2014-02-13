import haxe.unit.TestRunner;

class TestMain
{
	public static function main()
	{
		var r = new TestRunner();
		r.add(new TestImport());
		r.add(new TestMasks());
		r.add(new TestScreen());
		r.add(new TestScene());
		r.run();
	}
}
