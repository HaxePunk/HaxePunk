#ifdef GL_ES
	precision mediump float;
#endif

varying vec2 vTexCoord;
uniform sampler2D uImage0;

void main(void)
{
	gl_FragColor = texture2D(uImage0, vTexCoord).bgra;
	// gl_FragColor = vec4(1, 0, 1, 1);
}
