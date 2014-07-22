package com.haxepunk;

/**
 * The render mode used by HaxePunk.
 * Normal mode for flash&html5 is buffer, others are hardware.
 * To change the mode used see the com.haxepunk.Engine constructor,
 * but beware that things may not work if you do that.
 */
enum RenderMode
{
	/** Use a buffer which will be rendered to the screen. To be used only by flash and html5 targets. */
	BUFFER;
	
	/** Use an optimized rendering, won't work on flash or html5 targets. */
	HARDWARE;
}
