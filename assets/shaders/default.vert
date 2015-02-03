#ifdef GL_ES
	precision mediump float;
#endif

attribute vec2 aVertexPosition;
attribute vec2 aTexCoord;
attribute vec4 aColor;

varying vec2 vTexCoord;
varying vec4 vColor;

uniform mat4 uMatrix;

void main(void)
{
	vTexCoord = aTexCoord;
	vColor = aColor;
	gl_Position = uMatrix * vec4(aVertexPosition, 0.0, 1.0);
}
