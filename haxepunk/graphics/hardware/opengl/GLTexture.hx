package haxepunk.graphics.hardware.opengl;

#if lime
typedef GLTexture = lime.graphics.opengl.GLTexture;
#elseif nme
typedef GLTexture = flash.gl.GLTexture;
#else
typedef GLTexture = UInt;
#end
