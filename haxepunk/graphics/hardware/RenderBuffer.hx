package haxepunk.graphics.hardware;

#if js
import js.html.Int32Array;
#end
import haxepunk.graphics.hardware.opengl.GL;
import haxepunk.graphics.hardware.opengl.GLBuffer;
import haxepunk.graphics.hardware.opengl.GLUtils;

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
	var intOffset:Int;
	#end

	#if cpp
	var bytesData:haxe.io.BytesData;
	#end

	var byteOffset:Int;

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
		if (GLUtils.invalid(glBuffer))
		{
			buffer = null;
			init();
		}
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

	public function reset()
	{
#if cpp
		byteOffset = buffer.byteOffset;
		bytesData = buffer.buffer.getData();
#else
		byteOffset = 0;
	#if js
		intOffset = 0;
	#end
#end
	}

	public inline function addVec(x:Float, y:Float)
	{
#if cpp
		var bytesData = bytesData;
		var offset = byteOffset; // helps hxcpp generator
		untyped __global__.__hxcpp_memory_set_float(bytesData, offset, x);
		untyped __global__.__hxcpp_memory_set_float(bytesData, offset+4, y);
		byteOffset = offset + 8;
#else
		buffer[byteOffset] = x;
		buffer[byteOffset+1] = y;
		byteOffset += 2;
#end
	}

	public inline function addInt(value:Int)
	{
#if cpp
		untyped __global__.__hxcpp_memory_set_ui32(bytesData, byteOffset, value);
		byteOffset += 4;
#elseif js
		intArray[intOffset] = value;
		intOffset += 1;
#else
		buffer[byteOffset] = value;
		byteOffset += 1;
#end
	}

	public inline function updateGraphicsCard()
	{
		#if (lime >= "4.0.0")
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, length * Float32Array.BYTES_PER_ELEMENT, buffer);
		#else
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, buffer);
		#end
	}

	public function prepareVertexOnly(drawCommand:DrawCommand)
	{
		for (tri in drawCommand.triangles)
		{
			addVec(tri.tx1, tri.ty1);
			addVec(tri.tx2, tri.ty2);
			addVec(tri.tx3, tri.ty3);
		}
	}

	public function prepareVertexAndColor(drawCommand:DrawCommand)
	{
		var triangleColor:UInt = 0;
		for (tri in drawCommand.triangles)
		{
			triangleColor = tri.color.withAlpha(tri.alpha);

			addVec(tri.tx1, tri.ty1);
			addInt(triangleColor);

			addVec(tri.tx2, tri.ty2);
			addInt(triangleColor);

			addVec(tri.tx3, tri.ty3);
			addInt(triangleColor);
		}
	}

	public function prepareVertexAndUV(drawCommand:DrawCommand)
	{
		for (tri in drawCommand.triangles)
		{
			addVec(tri.tx1, tri.ty1);
			addVec(tri.uvx1, tri.uvy1);

			addVec(tri.tx2, tri.ty2);
			addVec(tri.uvx2, tri.uvy2);

			addVec(tri.tx3, tri.ty3);
			addVec(tri.uvx3, tri.uvy3);
		}
	}

	public function prepareVertexUVandColor(drawCommand:DrawCommand)
	{
		var triangleColor:UInt = 0;
		for (tri in drawCommand.triangles)
		{
			triangleColor = tri.color.withAlpha(tri.alpha);

			addVec(tri.tx1, tri.ty1);
			addVec(tri.uvx1, tri.uvy1);
			addInt(triangleColor);

			addVec(tri.tx2, tri.ty2);
			addVec(tri.uvx2, tri.uvy2);
			addInt(triangleColor);

			addVec(tri.tx3, tri.ty3);
			addVec(tri.uvx3, tri.uvy3);
			addInt(triangleColor);
		}
	}
}
