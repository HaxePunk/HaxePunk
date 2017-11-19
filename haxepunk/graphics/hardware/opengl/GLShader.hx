package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLShader = lime.graphics.opengl.GLShader;
#elseif nme
typedef GLShader = flash.gl.GLShader;
#else
typedef GLShader = UInt;
#end
