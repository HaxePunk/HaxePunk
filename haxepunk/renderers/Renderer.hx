package haxepunk.renderers;

import haxepunk.graphics.Color;

#if flash

typedef ShaderProgram = flash.display3D.Program3D;

#else

typedef ShaderProgram = lime.graphics.GLProgram;

#end

interface Renderer
{
	public function clear(color:Color):Void;
	public function compileShaderProgram(vertex:String, fragment:String):ShaderProgram;
	public function bindProgram(program:ShaderProgram):Void;
}
