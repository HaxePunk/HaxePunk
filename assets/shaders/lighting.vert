#ifdef GL_ES
	precision mediump float;
#endif

attribute vec3 aVertexPosition;
attribute vec2 aTexCoord;
attribute vec3 aNormal;
attribute vec3 aLightPos;

varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec4 vPosition;
varying vec3 vLightPos;

uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

void main(void)
{
	vPosition = uModelViewMatrix * vec4(aVertexPosition, 1.0);
	vNormal = normalize(aNormal);
	vTexCoord = aTexCoord;
	vLightPos = aLightPos;
	gl_Position = uProjectionMatrix * vPosition;
}
