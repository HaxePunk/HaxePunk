package haxepunk;

/**
 * A Signal binds one or more callback functions that will be called when
 * something interesting happens. Signals call their callbacks with no
 * arguments and expect no return value.
 * @:since 4.0.0
 */
class Signal<T>
{
	var callbacks:Array<T>;

	public function new()
	{
		callbacks = new Array();
	}

	public inline function exists(callback:T)
	{
		return callbacks.indexOf(callback) > -1;
	}

	public inline function bind(callback:T)
	{
		callbacks.push(callback);
	}

	public inline function remove(callback:T)
	{
		callbacks.remove(callback);
	}

	public inline function clear()
	{
		while (callbacks.length > 0)
		{
			callbacks.pop();
		}
	}
}

class Signal0 extends Signal<Void->Void>
{
	public inline function invoke():Void
	{
		for (callback in callbacks) callback();
	}
}

class Signal1<A> extends Signal<A->Void>
{
	public inline function invoke(a:A):Void
	{
		for (callback in callbacks) callback(a);
	}
}

class Signal2<A, B> extends Signal<A->B->Void>
{
	public inline function invoke(a:A, b:B):Void
	{
		for (callback in callbacks) callback(a, b);
	}
}

/**
 * A collection of named signals, which can be accessed as attributes.
 */
class Signals implements Dynamic<Signal0>
{
	var signals:Map<String, Signal0> = new Map();

	public function new() {}

	public inline function exists(field:String) return signals.exists(field);

	public inline function invoke(field:String)
	{
		if (exists(field)) signals[field].invoke();
	}

	public function resolve(field:String):Signal0
	{
		if (!exists(field)) signals[field] = new Signal0();
		return signals[field];
	}
}
