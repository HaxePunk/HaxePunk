package haxepunk.renderers;

import haxepunk.graphics.Color;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

enum BufferUsage {
	STATIC_DRAW;
	DYNAMIC_DRAW;
}

#if flash

typedef ShaderProgram = flash.display3D.Program3D;
typedef VertexBuffer = flash.display3D.VertexBuffer3D;
typedef IndexBuffer = flash.display3D.IndexBuffer3D;

#else

typedef ShaderProgram = lime.graphics.GLProgram;
typedef VertexBuffer = lime.graphics.GLBuffer;
typedef IndexBuffer = lime.graphics.GLBuffer;

#end

interface Renderer
{
	public function clear(color:Color):Void;
	public function present():Void;
	public function compileShaderProgram(vertex:String, fragment:String):ShaderProgram;
	public function bindProgram(program:ShaderProgram):Void;

	public function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer;
	public function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer;

	public function bindBuffer(v:VertexBuffer):Void;

	public function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void;
}
