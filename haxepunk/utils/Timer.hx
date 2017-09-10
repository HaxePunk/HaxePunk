package haxepunk.utils;

class Timer
{
	public static function getSeconds():Float
	{
#if (openfl || nme)
		return flash.Lib.getTimer() / 1000.0;
#else
		return haxe.Timer.stamp();
#end
	}

	public static function getMillis():Int
	{
#if (openfl || nme)
		return flash.Lib.getTimer();
#else
		return Std.int(haxe.Timer.stamp() * 1000);
#end
	}

	/**
	 * Sets a time flag.
	 * @return	Time elapsed (in milliseconds) since the last time flag was set.
	 */
	public static function flag():Int
	{
		var timestamp = Timer.getMillis(),
			elapsed = timestamp - lastTimeFlag;
		lastTimeFlag = timestamp;
		return elapsed;
	}
	static var lastTimeFlag:Int = 0;
}
