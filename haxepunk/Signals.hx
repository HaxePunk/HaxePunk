package haxepunk;

class Signals implements Dynamic<Signal>
{
	var signals:Map<String, Signal> = new Map();

	public function new() {}

	public inline function exists(field:String) return signals.exists(field);

	public inline function invoke(field:String)
	{
		if (exists(field)) signals[field].invoke();
	}

	public function resolve(field:String):Signal
	{
		if (!exists(field)) signals[field] = new Signal();
		return signals[field];
	}
}
