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

@:enum abstract BlendFactor(Int) to (Int) {
	var ZERO = 0;
	var ONE = 1;
	var SOURCE_ALPHA = 2;
	var SOURCE_COLOR = 3;
	var DEST_ALPHA = 4;
	var DEST_COLOR = 5;
	var ONE_MINUS_SOURCE_ALPHA = 6;
	var ONE_MINUS_SOURCE_COLOR = 7;
	var ONE_MINUS_DEST_ALPHA = 8;
	var ONE_MINUS_DEST_COLOR = 9;
}

@:enum abstract DepthTestCompare(Int) to (Int) {
	var ALWAYS = 0;
	var NEVER = 1;
	var EQUAL = 2;
	var NOT_EQUAL = 3;
	var GREATER = 4;
	var GREATER_EQUAL = 5;
	var LESS = 6;
	var LESS_EQUAL = 7;
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
