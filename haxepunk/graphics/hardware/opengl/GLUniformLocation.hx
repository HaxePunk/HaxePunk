package haxepunk.graphics.hardware.opengl;

#if js
typedef GLUniformLocation = js.html.webgl.UniformLocation;
#elseif lime
typedef GLUniformLocation = lime.graphics.opengl.GLUniformLocation;
#elseif nme
typedef GLUniformLocation = flash.gl.GLUniformLocation;
#else
typedef GLUniformLocation = UInt;
#end
