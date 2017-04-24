package haxepunk;

import massive.munit.Assert;

class BaseTest
{
	function assertThrows(expectedType:Dynamic, code:Dynamic, ?info:haxe.PosInfos):Dynamic
	{
		try
		{
			code();
			Assert.fail("Expected exception wasn't thrown!", info);
			return null; // needed to compile
		}
		catch (e:Dynamic)
		{
			if (Std.is(e, expectedType))
			{
				return e;
			}
			else
			{
				Assert.fail('Expected exception of type ${Type.getClassName(expectedType)} but got ${Type.getClassName(Type.getClass(e))}: ${e}');
				return null; // needed to compile
			}
		}
	}
}
