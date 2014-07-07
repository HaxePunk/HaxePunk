package haxepunk.renderers;

#if flash

import com.adobe.utils.AGALMiniAssembler;
import haxepunk.graphics.Color;
import haxepunk.renderers.Renderer;
import flash.Lib;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
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
			this.context.configureBackBuffer(context.stage.stageWidth, context.stage.stageHeight, 0, true);
			this.context.enableErrorChecking = true;
			ready();
		});
		stage3D.requestContext3D();
	}

	public function clear(color:Color):Void
	{
		context.clear(color.r, color.g, color.b, color.a);
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

	public function bindBuffer(v:VertexBuffer):Void
	{
		context.setVertexBufferAt(0, v);
	// 	context.setVertexBufferAt(1, v, 3, FLOAT_2);
	// 	context.setVertexBufferAt(2, v, 5, FLOAT_3);
	}

	public function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer
	{
		var buffer = context.createVertexBuffer(data.length, 1);
		buffer.uploadFromByteArray(data.buffer, 0, 0, data.length);
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
		texture.uploadFromBitmapData(image.data);
		return texture;
	}

	public function bindTexture(texture:NativeTexture):Void
	{
		context.setTextureAt(0, texture);
	}

	public function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		context.drawTriangles(i, offset, numTriangles);
	}

	public function setDepthTest(depthMask:Bool, test:DepthTestCompare):Void
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
