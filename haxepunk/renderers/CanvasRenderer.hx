package haxepunk.renderers;

import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.math.Rectangle;
import haxepunk.renderers.Renderer;
import lime.graphics.CanvasRenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.graphics.Image;

#if !doc-gen

class CanvasRenderer
{

	public static inline function init(context:CanvasRenderContext)
	{
		_viewport = new Rectangle();
		_context = context;
	}

	public static inline function clear(color:Color):Void
	{
		_context.fillStyle = color.toHexCode();
		_context.fillRect(_viewport.x, _viewport.y, _viewport.width, _viewport.height);
	}

	public static inline function present():Void
	{

	}

	public static inline function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		return 0;
	}

	public static inline function bindProgram(program:ShaderProgram):Void
	{

	}

	public static inline function setAttribute(a:Int, offset:Int, num:Int):Void
	{

	}

	public static inline function bindBuffer(v:VertexBuffer):Void
	{

	}

	public static inline function updateBuffer(data:Float32Array, stride:Int, ?usage:BufferUsage, ?buffer:VertexBuffer):VertexBuffer
	{
		return 0;
	}

	public static inline function updateIndexBuffer(data:Int16Array, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer
	{
		return 0;
	}

	public static inline function setMatrix(loc:Location, matrix:Matrix4):Void
	{

	}

	public static inline function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{

	}

	public static inline function setCullMode(mode:CullMode):Void
	{

	}

	public static inline function createTexture(image:Image):NativeTexture
	{
		return image.src;
	}

	public static inline function bindTexture(texture:NativeTexture, sampler:Int):Void
	{

	}

	public static inline function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{

	}

	public static inline function setViewport(x:Int, y:Int, width:Int, height:Int):Void
	{
		_viewport.x = x;
		_viewport.y = y;
		_viewport.width = width;
		_viewport.height = height;
	}

	public static inline function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{

	}

	private static var _viewport:Rectangle;
	private static var _context:CanvasRenderContext;

}

#end
