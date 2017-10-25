package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLProgram = lime.graphics.opengl.GLProgram;
#else
typedef GLProgram = flash.gl.GLProgram;
#end
