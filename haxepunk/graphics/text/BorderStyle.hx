package haxepunk.graphics.text;

@:enum
abstract BorderStyle(Int) from Int to Int
{
	/* Draws a thick shadow down and to the right. */
	var Shadow = 1;
	/* Draws a shadow using only one draw call. */
	var FastShadow = 2;
	/* Outlines the text on all sides. */
	var Outline = 3;
	/* A fast outline in four draw calls. */
	var FastOutline = 4;
}
