package haxepunk.renderers;

import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.graphics.Image;

class NullRenderer
{

	public static inline function new() { }

	public static inline function clear(color:Color):Void { }

	public static inline function present():Void { }

	public static inline function compileShaderProgram(vertex:String, fragment:String):ShaderProgram { return null; }

	public static inline function bindProgram(program:ShaderProgram):Void { }

	public static inline function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer { return null; }

	public static inline function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer { return null; }

	public static inline function bindBuffer(v:VertexBuffer):Void { }

	public static inline function setMatrix(loc:Location, matrix:Matrix4):Void { }

	public static inline function setAttribute(a:Int, offset:Int, num:Int, stride:Int):Void { }

	public static inline function setBlendMode(source:BlendFactor, destination:BlendFactor):Void { }

	public static inline function setCullMode(mode:CullMode):Void { }

	public static inline function createTexture(image:Image):NativeTexture { return null; }

	public static inline function deleteTexture(texture:NativeTexture):Void { }

	public static inline function bindTexture(texture:NativeTexture, sampler:Int):Void { }

	public static inline function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void { }

	public static inline function setViewport(x:Int, y:Int, width:Int, height:Int):Void { }

	public static inline function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void { }

}
