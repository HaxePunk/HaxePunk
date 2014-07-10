package haxepunk.renderers;

import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.math.Rectangle;
import haxepunk.renderers.Renderer;
import lime.graphics.CanvasRenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.graphics.Image;

class CanvasRenderer implements Renderer
{

	public function new(context:CanvasRenderContext)
	{
		_viewport = new Rectangle();
		_context = context;
	}

	public function clear(color:Color):Void
	{
		_context.fillStyle = color.toHexCode();
		_context.fillRect(_viewport.x, _viewport.y, _viewport.width, _viewport.height);
	}

	public function present():Void
	{

	}

	public function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		return null;
	}

	public function bindProgram(program:ShaderProgram):Void
	{

	}

	public function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer
	{
		return null;
	}

	public function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer
	{
		return null;
	}

	public function bindBuffer(v:VertexBuffer):Void
	{

	}

	public function setMatrix(loc:Location, matrix:Matrix4):Void
	{

	}

	public function setAttribute(a:Int, offset:Int, num:Int, stride:Int):Void
	{

	}

	public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{

	}

	public function setCullMode(mode:CullMode):Void
	{

	}

	public function createTexture(image:Image):NativeTexture
	{
		return null;
	}

	public function bindTexture(texture:NativeTexture, sampler:Int):Void
	{

	}

	public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{

	}

	public function setViewport(x:Int, y:Int, width:Int, height:Int):Void
	{
		_viewport.x = x;
		_viewport.y = y;
		_viewport.width = width;
		_viewport.height = height;
	}

	public function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{

	}

	private var _viewport:Rectangle;
	private var _context:CanvasRenderContext;

}
