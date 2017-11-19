package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLUniformLocation = lime.graphics.opengl.GLUniformLocation;
#elseif nme
typedef GLUniformLocation = flash.gl.GLUniformLocation;
#else
typedef GLUniformLocation = UInt;
#end
