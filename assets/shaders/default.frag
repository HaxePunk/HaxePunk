#ifdef GL_ES
	precision mediump float;
#endif

varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec4 vPosition;

uniform sampler2D uImage0;

void main(void)
{
	vec3 light = normalize(vec3(0, 0, -1) - vPosition.xyz);
	float NdotL = max(dot(vNormal, light), 0.0);
	gl_FragColor = vec4(texture2D(uImage0, vTexCoord).rgb * NdotL, 1.0);
	// gl_FragColor = texture2D(uImage0, vTexCoord);
}
