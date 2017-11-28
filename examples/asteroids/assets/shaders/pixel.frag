#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vTexCoord;
uniform sampler2D uImage0;
uniform vec2 uResolution;

const float COLOR_VALUES = 16.0;
const float SCALE = 3.0;

vec3 posterize(vec3 c) {
	return floor(c * COLOR_VALUES + 0.5) / COLOR_VALUES;
}

void main () {
	vec4 color = texture2D(uImage0, vec2(
		floor(0.5 + vTexCoord.x * uResolution.x / SCALE) * SCALE / uResolution.x,
		floor(0.5 + vTexCoord.y * uResolution.y / SCALE) * SCALE / uResolution.y
	));
	gl_FragColor = vec4(posterize(color.rgb), 1.0);
}
