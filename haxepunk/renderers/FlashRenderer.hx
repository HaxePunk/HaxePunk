package haxepunk.renderers;

#if flash

import com.adobe.flash.utils.AGALMiniAssembler;
import haxepunk.graphics.Color;
import haxepunk.renderers.Renderer;
import flash.Lib;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.events.Event;
import lime.graphics.FlashRenderContext;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

class FlashRenderer implements Renderer
{

	public function new(context:FlashRenderContext)
	{
		stage3D = context.stage.stage3Ds[0];
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreateContext);
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
		vertexAssembly.assemble(Context3DProgramType.VERTEX, vertex, false);

		var fragmentAssembly = new AGALMiniAssembler();
		fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, fragment, false);

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

	}

	public function createBuffer(data:Float32Array, ?usage:BufferUsage):VertexBuffer
	{
		var numVerts = 3; // TODO: don't hardcode this
		#if false
		var buffer = context.createVertexBuffer(data.length, numVerts, usage == DYNAMIC_DRAW ? "dynamicDraw" : "staticDraw");
		#else
		var buffer = context.createVertexBuffer(data.length, numVerts);
		#end
		buffer.uploadFromByteArray(data.buffer, 0, 0, data.length);
		return buffer;
	}

	public function createIndexBuffer(data:Int16Array, ?usage:BufferUsage):IndexBuffer
	{
		var buffer = context.createIndexBuffer(data.length);
		buffer.uploadFromByteArray(data.buffer, 0, 0, data.length);
		return buffer;
	}

	public function draw(i:IndexBuffer, numTriangles:Int, offset:Int=0):Void
	{
		context.drawTriangles(i, offset, numTriangles);
	}

	private function onCreateContext(_)
	{
		context = stage3D.context3D;
	}

	private var context:Context3D;
	private static var stage3D:Stage3D;

}

#end
