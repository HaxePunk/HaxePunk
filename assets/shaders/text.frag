#ifdef GL_ES
	precision mediump float;
#endif

varying vec2 vTexCoord;

uniform sampler2D uImage0;
uniform vec4 uColor;

void main(void)
{
	float alpha = texture2D(uImage0, vTexCoord).a;
	gl_FragColor = vec4(uColor.rgb, alpha);
}
