package haxepunk.utils;

class Utf8StringTest
{
	@Test
	public function testCharAt()
	{
		var u:Utf8String = "Haxe♥Punk";
		Assert.areEqual(0x2665, u.charCodeAt(4));
		Assert.areEqual("P".charCodeAt(0), u.charCodeAt(5));
		Assert.areEqual(9, u.length);
	}

	@Test
	public function testConversion()
	{
		var s:String = "abc";
		var u:Utf8String = s;
		var s2:String = u;
		Assert.areEqual(s, u);
		Assert.areEqual(s, s2);
	}
}
