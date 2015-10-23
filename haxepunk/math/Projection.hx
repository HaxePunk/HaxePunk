package haxepunk.math;

class Projection
{

	public var max:Float;
	public var min:Float;

	/**
	 * Constructor.
	 */
	public function new(min:Float=0, max:Float=0):Void
	{
		this.min = min;
		this.max = max;
	}

	/**
	 * Check if two projection overlap.
	 * @param	other	The other projection
	 * @return	If they overlap.
	 */
	public inline function overlaps(other:Projection):Bool
	{
		return !(min > other.max || max < other.min);
	}

	/**
	 * Get the value of two projection overlap.
	 * @param	other	The other projection
	 * @return	The overlap value.
	 */
	public inline function getOverlap(other:Projection):Float
	{
		return (max > other.max) ? max - other.min : other.max - min;
	}

	/**
	 * Prints the projection as a string
	 * @return	String version of the object.
	 */
	public function toString():String
	{
		return '[$min --> $max]';
	}

}
