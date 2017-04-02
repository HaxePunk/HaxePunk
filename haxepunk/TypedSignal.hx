package haxepunk;

private typedef SignalCallback<T> = T->Void;

/**
 * A Signal binds one or more callback functions that will be called when
 * something interesting happens.
 *
 * Signals call their callbacks with no arguments and expect no return value.
 */
@:generic class TypedSignal<T>
{
	var callbacks:Array<SignalCallback<T>>;

	public function new()
	{
		callbacks = new Array();
	}

	public inline function exists(callback:SignalCallback<T>)
	{
		return callbacks.indexOf(callback) > -1;
	}

	public inline function bind(callback:SignalCallback<T>)
	{
		callbacks.push(callback);
	}

	public inline function remove(callback:SignalCallback<T>)
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

	public inline function invoke(value:T):Void
	{
		for (callback in callbacks) callback(value);
	}
}
