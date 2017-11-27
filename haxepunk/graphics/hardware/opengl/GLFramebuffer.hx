package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLFramebuffer = lime.graphics.opengl.GLFramebuffer;
#elseif nme
typedef GLFramebuffer = flash.gl.GLFramebuffer;
#else
typedef GLFramebuffer = UInt;
#end
