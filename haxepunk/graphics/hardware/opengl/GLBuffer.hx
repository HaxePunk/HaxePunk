package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLBuffer = lime.graphics.opengl.GLBuffer;
#else
typedef GLBuffer = flash.gl.GLBuffer;
#end
