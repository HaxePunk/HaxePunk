package haxepunk.renderers;

#if flash

import com.adobe.utils.AGALMiniAssembler;
import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import flash.Lib;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
// import flash.display3D.Context3DBufferUsage;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import lime.graphics.FlashRenderContext;
import lime.graphics.Image;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

class FlashRenderer implements Renderer
{

	public function new(context:FlashRenderContext, ready:Void->Void)
	{
		stage3D = context.stage.stage3Ds[0];
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, function (_) {
			_context = stage3D.context3D;
			setViewport(0, 0, context.stage.stageWidth, context.stage.stageHeight);
			_context.enableErrorChecking = true;
			ready();
		});
		stage3D.requestContext3D();
	}

	public function clear(color:Color):Void
	{
		_context.clear(color.r, color.g, color.b, color.a);
	}

	public function setViewport(x:Int, y:Int, width:Int, height:Int):Void
	{
		stage3D.x = x;
		stage3D.y = y;
		_context.configureBackBuffer(width, height, 0);
	}

	public function present()
	{
		_context.present();
	}

	public function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var vertexAssembly = new AGALMiniAssembler();
		vertexAssembly.assemble(Context3DProgramType.VERTEX, vertex);

		var fragmentAssembly = new AGALMiniAssembler();
		fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, fragment);

		var program = _context.createProgram();
		program.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);

		return program;
	}

	public function bindProgram(program:ShaderProgram):Void
	{
		_context.setProgram(program);
	}

	public function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, loc, matrix.native, false);
	}

	public function setAttribute(a:Int, offset:Int, num:Int, stride:Int):Void
	{
		_context.setVertexBufferAt(a, _activeBuffer, offset, FORMAT[num]);
	}

	public function bindBuffer(buffer:VertexBuffer):Void
	{
		_activeBuffer = buffer;
	}

	public function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer
	{
		var stride = 8;
		var len:Int = Std.int(data.length / stride);
		var buffer = _context.createVertexBuffer(len, stride);
		buffer.uploadFromByteArray(data.buffer, 0, 0, len);
		return buffer;
	}

	public function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer
	{
		var buffer = _context.createIndexBuffer(data.length);
		buffer.uploadFromByteArray(data.buffer, 0, 0, data.length);
		return buffer;
	}

	public function createTexture(image:Image):NativeTexture
	{
		var texture = _context.createTexture(image.width, image.height, Context3DTextureFormat.BGRA, true);
		texture.uploadFromBitmapData(image.src);
		return texture;
	}

	public function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		_context.setTextureAt(sampler, texture);
	}

	public function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		_context.drawTriangles(buffer, offset, numTriangles);
	}

	public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		_context.setBlendFactors(BLEND[source], BLEND[destination]);
	}

	public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (depthMask)
		{
			_context.setDepthTest(true, COMPARE[test]);
		}
		else
		{
			_context.setDepthTest(false, Context3DCompareMode.NEVER);
		}
	}

	private var _context:Context3D;
	private var _activeBuffer:VertexBuffer3D;
	private var stage3D:Stage3D;

	private static var BLEND = [
		Context3DBlendFactor.ZERO,
		Context3DBlendFactor.ONE,
		Context3DBlendFactor.SOURCE_ALPHA,
		Context3DBlendFactor.SOURCE_COLOR,
		Context3DBlendFactor.DESTINATION_ALPHA,
		Context3DBlendFactor.DESTINATION_COLOR,
		Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA,
		Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR,
		Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,
		Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR
	];

	static var COMPARE = [
		Context3DCompareMode.ALWAYS,
		Context3DCompareMode.NEVER,
		Context3DCompareMode.EQUAL,
		Context3DCompareMode.NOT_EQUAL,
		Context3DCompareMode.GREATER,
		Context3DCompareMode.GREATER_EQUAL,
		Context3DCompareMode.LESS,
		Context3DCompareMode.LESS_EQUAL,
	];

	private static var FORMAT = [
		Context3DVertexBufferFormat.BYTES_4,
		Context3DVertexBufferFormat.FLOAT_1,
		Context3DVertexBufferFormat.FLOAT_2,
		Context3DVertexBufferFormat.FLOAT_3,
		Context3DVertexBufferFormat.FLOAT_4,
	];

}

#end
