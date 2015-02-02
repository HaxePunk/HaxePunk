package haxepunk.debug;

class HistoryQueue<T> implements ArrayAccess<T>
{

	public var length(get, never):Int;
	private inline function get_length():Int { return _queue.length; }

	public function new(max:Int)
	{
		_maxSize = max;
		_queue = new Array<T>();
	}

	public function add(value:T):Int
	{
		if (_queue.length + 1 > _maxSize)
		{
			_queue.shift();
		}
		return _queue.push(value);
	}

	public function iterator():Iterator<T>
	{
		return _queue.iterator();
	}

	public function toString():String
	{
		return _queue.toString();
	}

	public function __set(index:Int, value:T):Void
	{
		throw "HistoryQueue does not allow values to be directly set using brackets []";
	}

	public function __get(index:Int):T
	{
		return _queue[index];
	}

	private var _maxSize:Int;
	private var _queue:Array<T>;

}
