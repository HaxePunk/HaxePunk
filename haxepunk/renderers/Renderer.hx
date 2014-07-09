package haxepunk.renderers;

import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.graphics.Image;

enum BufferUsage {
	STATIC_DRAW;
	DYNAMIC_DRAW;
}

enum BlendFactor {
	ONE;
	ZERO;
	SOURCE_ALPHA;
	DESTINATION_COLOR;
	ONE_MINUS_SOURCE_ALPHA;
	ONE_MINUS_SOURCE_COLOR;
}

enum DepthTestCompare {
	NEVER;
	ALWAYS;
	EQUAL;
	GREATER;
	GREATER_EQUAL;
	LESS;
	LESS_EQUAL;
	NOT_EQUAL;
}

#if flash

typedef ShaderProgram = flash.display3D.Program3D;
typedef VertexBuffer = flash.display3D.VertexBuffer3D;
typedef IndexBuffer = flash.display3D.IndexBuffer3D;
typedef NativeTexture = flash.display3D.textures.Texture;
typedef Location = Int;

#else

typedef ShaderProgram = lime.graphics.GLProgram;
typedef VertexBuffer = lime.graphics.GLBuffer;
typedef IndexBuffer = lime.graphics.GLBuffer;
typedef NativeTexture = lime.graphics.GLTexture;
typedef Location = lime.graphics.GLUniformLocation;

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

	public function setMatrix(loc:Location, matrix:Matrix4):Void;
	public function setAttribute(a:Int, offset:Int, num:Int, stride:Int):Void;
	public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void;

	public function createTexture(image:Image):NativeTexture;
	public function bindTexture(texture:NativeTexture, sampler:Int):Void;

	public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void;
	public function setViewport(x:Int, y:Int, width:Int, height:Int):Void;

	public function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void;
}
