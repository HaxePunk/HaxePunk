#ifdef GL_ES
	precision mediump float;
#endif

attribute vec3 aVertexPosition;
attribute vec2 aTexCoord;
attribute vec3 aNormal;

varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec4 vPosition;

uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

void main(void)
{
	vPosition = vec4(aVertexPosition, 1.0);
	vNormal = normalize(aNormal);
	vTexCoord = aTexCoord;
	gl_Position = uProjectionMatrix * uModelViewMatrix * vPosition;
}
