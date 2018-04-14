package haxepunk.graphics.hardware;

import nme.utils.Float32Array as F32Array;

@:forward
@:arrayAccess
abstract Float32Array(F32Array) from F32Array to F32Array
{
	public static inline var BYTES_PER_ELEMENT = F32Array.SBYTES_PER_ELEMENT;

	public function new(inBufferOrArray:Dynamic, inStart:Int = 0, ?inElements:Null<Int>)
	{
		return new F32Array(inBufferOrArray, inStart, inElements);
	}
}
