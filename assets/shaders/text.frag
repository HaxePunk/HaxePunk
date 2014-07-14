#ifdef GL_ES
	precision mediump float;
#endif

varying vec2 vTexCoord;

uniform sampler2D uImage0;
uniform vec4 uColor;
uniform float uWidth;
uniform float uHeight;

void main(void)
{
	float x = 1.0 / uWidth;
	float y = 1.0 / uHeight;

	float middle = texture2D(uImage0, vTexCoord).a;
	float tl = texture2D(uImage0, vTexCoord + vec2( -x, -y)).a;
	float tm = texture2D(uImage0, vTexCoord + vec2(0.0, -y)).a;
	float tr = texture2D(uImage0, vTexCoord + vec2(  x, -y)).a;

	float bl = texture2D(uImage0, vTexCoord + vec2( -x,  y)).a;
	float br = texture2D(uImage0, vTexCoord + vec2(  x,  y)).a;
	float bm = texture2D(uImage0, vTexCoord + vec2(0.0,  y)).a;

	float ml = texture2D(uImage0, vTexCoord + vec2( -x, 0.0)).a;
	float mr = texture2D(uImage0, vTexCoord + vec2(  x, 0.0)).a;

	vec3 a = (vec3(tl, tm * 2.0, tr) - vec3(bl, bm * 2.0, br)) * middle;
	vec3 b = (vec3(bl, ml * 2.0, tl) - vec3(br, mr * 2.0, tr)) * middle;

	vec3 c = (a * a + b * b);

	gl_FragColor = vec4(uColor.rgb, c);
}
