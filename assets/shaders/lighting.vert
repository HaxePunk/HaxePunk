#ifdef GL_ES
	precision mediump float;
#endif

uniform mat4 uMatrix;
uniform vec3 uLightPos;

attribute vec4 aVertexPosition;
attribute vec2 aTexCoord;
attribute vec3 aNormal;

varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec3 vLightDir;

void main(void)
{
	vNormal = normalize(-uMatrix * vec4(aNormal, 0.0)).xyz;
	vLightDir = normalize(uLightPos);
	vTexCoord = aTexCoord;
	gl_Position = uMatrix * aVertexPosition;
}
