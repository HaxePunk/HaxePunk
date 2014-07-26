#ifdef GL_ES
	precision mediump float;
#endif

uniform vec4 uDiffuseColor;
uniform vec4 uAmbientColor;
uniform vec4 uSpecularColor;
uniform vec4 uEmissiveColor;

uniform sampler2D uImage0;

varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec3 vLightDir;

void main(void)
{
	float NdotL = max(dot(vNormal, vLightDir), 0.0);
	vec4 diffuse = uDiffuseColor;
	gl_FragColor = uAmbientColor + (texture2D(uImage0, vTexCoord) + diffuse) * NdotL;
}
