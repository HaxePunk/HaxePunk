package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLBuffer = lime.graphics.opengl.GLBuffer;
#elseif nme
typedef GLBuffer = flash.gl.GLBuffer;
#else
typedef GLBuffer = UInt;
#end
