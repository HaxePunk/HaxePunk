package haxepunk;

class Signals implements Dynamic<Signal>
{
	var signals:Map<String, Signal> = new Map();

	public function new() {}

	public inline function exists(field:String) return signals.exists(field);

	public inline function invokeIf(field:String)
	{
		if (exists(field))
		{
			signals[field].invoke();
		}
	}

	function resolve(field:String):Signal
	{
		if (!signals.exists(field))
		{
			signals[field] = new Signal();
		}
		return signals[field];
	}
}
