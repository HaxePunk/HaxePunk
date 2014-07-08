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
import flash.display3D.textures.Texture;
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
			this.context = stage3D.context3D;
			setViewport(context.stage.stageWidth, context.stage.stageHeight);
			this.context.enableErrorChecking = true;
			ready();
		});
		stage3D.requestContext3D();
	}

	public function clear(color:Color):Void
	{
		context.clear(color.r, color.g, color.b, color.a);
	}

	public function setViewport(width:Int, height:Int):Void
	{
		context.configureBackBuffer(width, height, 0);
	}

	public function present()
	{
		context.present();
	}

	public function compileShaderProgram(vertex:String, fragment:String):ShaderProgram
	{
		var vertexAssembly = new AGALMiniAssembler();
		vertexAssembly.assemble(Context3DProgramType.VERTEX, vertex);

		var fragmentAssembly = new AGALMiniAssembler();
		fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, fragment);

		var program = context.createProgram();
		program.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);

		return program;
	}

	public function bindProgram(program:ShaderProgram):Void
	{
		context.setProgram(program);
	}

	public function setMatrix(loc:Location, matrix:Matrix4):Void
	{
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, loc, matrix.native, true);
	}

	public function bindBuffer(buffer:VertexBuffer):Void
	{
		context.setVertexBufferAt(0, buffer, 0, FLOAT_3);
		context.setVertexBufferAt(1, buffer, 3, FLOAT_2);
		context.setVertexBufferAt(2, buffer, 5, FLOAT_3);
	}

	public function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer
	{
		var stride = 8;
		var len:Int = Std.int(data.length / stride);
		var buffer = context.createVertexBuffer(len, stride);
		buffer.uploadFromByteArray(data.buffer, 0, 0, len);
		return buffer;
	}

	public function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer
	{
		var buffer = context.createIndexBuffer(data.length);
		buffer.uploadFromByteArray(data.buffer, 0, 0, data.length);
		return buffer;
	}

	public function createTexture(image:Image):NativeTexture
	{
		var texture = context.createTexture(image.width, image.height, Context3DTextureFormat.BGRA, true);
		texture.uploadFromBitmapData(image.src);
		return texture;
	}

	public function bindTexture(texture:NativeTexture, sampler:Int):Void
	{
		context.setTextureAt(sampler, texture);
	}

	public function draw(buffer:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		try {
			context.drawTriangles(buffer, offset, numTriangles);
		} catch (e:Dynamic) {
			trace(e);
		}
	}

	private inline function getBlendFactor(factor:BlendFactor):Context3DBlendFactor
	{
		return switch (factor) {
			case ONE: Context3DBlendFactor.ONE;
			case ZERO: Context3DBlendFactor.ZERO;
			case SOURCE_ALPHA: Context3DBlendFactor.SOURCE_ALPHA;
			case DESTINATION_COLOR: Context3DBlendFactor.DESTINATION_COLOR;
			case ONE_MINUS_SOURCE_ALPHA: Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case ONE_MINUS_SOURCE_COLOR: Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
		};
	}

	public function setBlendMode(source:BlendFactor, destination:BlendFactor):Void
	{
		context.setBlendFactors(getBlendFactor(source), getBlendFactor(destination));
	}

	public function setDepthTest(depthMask:Bool, ?test:DepthTestCompare):Void
	{
		if (depthMask)
		{
			switch (test)
			{
				case NEVER: context.setDepthTest(true, Context3DCompareMode.NEVER);
				case ALWAYS: context.setDepthTest(true, Context3DCompareMode.ALWAYS);
				case GREATER: context.setDepthTest(true, Context3DCompareMode.GREATER);
				case GREATER_EQUAL: context.setDepthTest(true, Context3DCompareMode.GREATER_EQUAL);
				case LESS: context.setDepthTest(true, Context3DCompareMode.LESS);
				case LESS_EQUAL: context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
				case EQUAL: context.setDepthTest(true, Context3DCompareMode.EQUAL);
				case NOT_EQUAL: context.setDepthTest(true, Context3DCompareMode.NOT_EQUAL);
			}
		}
		else
		{
			context.setDepthTest(false, Context3DCompareMode.NEVER);
		}
	}

	private var context:Context3D;
	private static var stage3D:Stage3D;

}

#end
