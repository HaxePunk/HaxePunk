package haxepunk.renderers;

#if flash

import haxepunk.graphics.Color;
import haxepunk.renderers.Renderer;
import lime.graphics.FlashRenderContext;

import com.adobe.flash.utils.AGALMiniAssembler;
import flash.Lib;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.events.Event;

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

	private function onCreateContext(_)
	{
		context = stage3D.context3D;
	}

	private var context:Context3D;
	private static var stage3D:Stage3D;

}

#end
