package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLProgram = lime.graphics.opengl.GLProgram;
#elseif nme
typedef GLProgram = flash.gl.GLProgram;
#else
typedef GLProgram = UInt;
#end
