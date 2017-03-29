package haxepunk;

private typedef SignalCallback = Void->Void;

/**
 * A Signal binds one or more callback functions that will be called when
 * something interesting happens.
 *
 * Signals call their callbacks with no arguments and expect no return value.
 */
class Signal
{
	var callbacks:Array<SignalCallback>;

	public function new()
	{
		callbacks = new Array();
	}

	public inline function exists(callback:SignalCallback)
	{
		return callbacks.indexOf(callback) > -1;
	}

	public inline function bind(callback:SignalCallback)
	{
		callbacks.push(callback);
	}

	public inline function remove(callback:SignalCallback)
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

	public inline function invoke():Void
	{
		for (callback in callbacks) callback();
	}
}
