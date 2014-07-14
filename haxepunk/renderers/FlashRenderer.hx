package haxepunk.renderers;

#if flash

import com.adobe.utils.AGALMiniAssembler;
import haxepunk.graphics.Color;
import haxepunk.math.Matrix4;
import haxepunk.renderers.Renderer;
import flash.Lib;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.*;
import flash.display3D.textures.Texture;
import flash.events.Event;
import lime.graphics.FlashRenderContext;
import lime.graphics.Image;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

class FlashRenderer
{

	public static inline function init(context:FlashRenderContext, ready:Void->Void)
	{
		_stage3D = context.stage.stage3Ds[0];
		_stage3D.addEventListener(Event.CONTEXT3D_CREATE, function (_) {
			_context = _stage3D.context3D;
			setViewport(0, 0, context.stage.stageWidth, context.stage.stageHeight);
			_context.enableErrorChecking = true;
			ready();
		});
		_stage3D.requestContext3D();
	}

	public static inline function clear(color:Color):Void
	{
		_context.clear(color.r, color.g, color.b, color.a);
	}

	public static inline function setCullMode(mode:CullMode):Void
	{
		_context.setCulling(CULL[mode]);
	}

	public static inline function setViewport(x:Int, y:Int, width:Int, height:Int):Void
	{
		_stage3D.x = x;
		_stage3D.y = y;
		_context.configureBackBuffer(width, height, 4, true);
	}

	public static inline function present()
	{
		_context.present();
	}

	public static inline function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var assembler = new AGALMiniAssembler();
		var vertexShader = assembler.assemble(Context3DProgramType.VERTEX, vertex);
		var fragmentShader = assembler.assemble(Context3DProgramType.FRAGMENT, fragment);

		var program = _context.createProgram();
		program.upload(vertexShader, fragmentShader);

		return program;
	}

	public static inline function bindProgram(program:ShaderProgram):Void
	{
		_context.setProgram(program);
	}

	public static inline function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		matrix.transpose(); // Flash requires a transposed matrix
		_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, loc, matrix.native, false);
	}

	public static inline function setColor(loc:Location, color:Color):Void
	{
		var vec = new flash.Vector();
		vec.push(color.r);
		vec.push(color.g);
		vec.push(color.b);
		vec.push(color.a);
		_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, loc, vec);
	}

	public static inline function setAttribute(a:Int, offset:Int, num:Int):Void
	{
		_context.setVertexBufferAt(a, _activeBuffer, offset, FORMAT[num]);
	}

	public static inline function bindBuffer(buffer:VertexBuffer):Void
	{
		_activeBuffer = buffer;
	}

	public static inline function updateBuffer(data:Float32Array, stride:Int, ?usage:BufferUsage, ?buffer:VertexBuffer):VertexBuffer
	{
		var len:Int = Std.int(data.length / stride);
		if (buffer == null) buffer = _context.createVertexBuffer(len, stride);
		buffer.uploadFromByteArray(data.buffer, 0, 0, len);
		return buffer;
	}

	public static inline function updateIndexBuffer(data:Int16Array, ?usage:BufferUsage, ?buffer:IndexBuffer):IndexBuffer
	{
		if (buffer == null) buffer = _context.createIndexBuffer(data.length);
		buffer.uploadFromByteArray(data.buffer, 0, 0, data.length);
		return buffer;
	}

	public static inline function createTexture(image:Image):NativeTexture
	{
		var texture = _context.createTexture(image.width, image.height, Context3DTextureFormat.BGRA, false);
		texture.uploadFromBitmapData(image.src, 0);
		return texture;
	}

	public static inline function deleteTexture(texture:NativeTexture):Void
	{
		texture.dispose();
	}

	public static inline function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		_context.setTextureAt(sampler, texture);
	}

	public static inline function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		_context.drawTriangles(buffer, offset, numTriangles);
	}

	public static inline function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		_context.setBlendFactors(BLEND[source], BLEND[destination]);
	}

	public static inline function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (depthMask)
		{
			_context.setDepthTest(true, COMPARE[test]);
		}
		else
		{
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
		}
	}

	private static var _context:Context3D;
	private static var _activeBuffer:VertexBuffer3D;
	private static var _stage3D:Stage3D;

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

	private static var CULL = [
		Context3DTriangleFace.NONE,
		Context3DTriangleFace.BACK,
		Context3DTriangleFace.FRONT,
		Context3DTriangleFace.FRONT_AND_BACK,
	];

}

#end
