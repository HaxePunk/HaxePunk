import haxe.unit.TestRunner;

class TestMain
{
	public static function main()
	{
		var r = new TestRunner();
		r.add(new TestImport());
		r.add(new masks.TestSlopedGrid());
		r.add(new masks.TestHitbox());
		r.add(new masks.TestCollide());
		r.add(new TestScreen());
		r.add(new TestScene());
		r.run();
	}
}
