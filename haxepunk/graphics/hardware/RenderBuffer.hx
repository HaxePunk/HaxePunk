package haxepunk.graphics.hardware;

#if js
import js.html.Int32Array;
#end
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;

class RenderBuffer
{
	static inline var INITIAL_SIZE:Int = 100;

	static inline function resize(length:Int, minChunks:Int, chunkSize:Int)
	{
		return Std.int(Math.max(
			Std.int(length * 2 / chunkSize),
			minChunks
		) * chunkSize);
	}

	public var buffer:Float32Array;
	public var glBuffer:GLBuffer;

	public var length(get, never):Int;
	inline function get_length() return buffer.length;

	#if js
	var intArray:Int32Array;
	#end

	public function new()
	{
		init();
	}

	public function init()
	{
		glBuffer = GL.createBuffer();
	}

	public function ensureSize(triangles:Int, floatsPerTriangle:Int)
	{
		var bufferLength = buffer == null ? 0 : buffer.length;
		if (bufferLength < triangles * floatsPerTriangle)
		{
			buffer = new Float32Array(resize(bufferLength, triangles, floatsPerTriangle));
			#if js
			intArray = new Int32Array(buffer.buffer);
			#end

			GL.bindBuffer(GL.ARRAY_BUFFER, glBuffer);
			#if (lime >= "4.0.0")
			GL.bufferData(GL.ARRAY_BUFFER, buffer.length * Float32Array.BYTES_PER_ELEMENT, buffer, GL.DYNAMIC_DRAW);
			#else
			GL.bufferData(GL.ARRAY_BUFFER, buffer, GL.DYNAMIC_DRAW);
			#end
		}
	}

	public inline function set(pos:Int, v:Float)
	{
		buffer[pos] = v;
	}

	public inline function setInt32(pos:Int, v:Int)
	{
		#if js
		intArray[pos] = v;
		#else
		buffer.buffer.setInt32(pos * 4, v);
		#end
	}
}
