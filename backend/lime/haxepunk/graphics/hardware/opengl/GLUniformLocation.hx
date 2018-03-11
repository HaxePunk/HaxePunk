package haxepunk.graphics.hardware.opengl;

#if js
typedef GLUniformLocation = js.html.webgl.UniformLocation;
#else
typedef GLUniformLocation = lime.graphics.opengl.GLUniformLocation;
#end
