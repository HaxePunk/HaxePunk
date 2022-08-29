package haxepunk.graphics.hardware;

import haxepunk.graphics.hardware.opengl.GL;
import haxepunk.graphics.hardware.opengl.GLFramebuffer;
import haxepunk.graphics.hardware.opengl.GLTexture;
import haxepunk.graphics.hardware.opengl.GLUtils;

@:dox(hide)
class FrameBuffer
{
	public var texture:GLTexture;

	var framebuffer:GLFramebuffer;

	var _width:Int = 0;
	var _height:Int = 0;

	public function new() {}

	public function build()
	{
		framebuffer = GL.createFramebuffer();
		resize();
	}

	public function destroy()
	{
		texture = null;
	}

	/**
	 * Rebuilds the renderbuffer to match screen dimensions
	 */
	public function resize()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);

		if (texture != null) GL.deleteTexture(texture);

		_width = HXP.screen.width;
		_height = HXP.screen.height;
		createTexture(_width, _height);
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}

	inline function createTexture(width:Int, height:Int)
	{
		texture = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, texture);
		#if (html5 && lime >= "5.0.0")
		GL.texImage2DWEBGL(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE);
		#else
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, #if ((lime >= "4.0.0") && (cpp || hl)) 0 #else null #end);
		#end

		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER , GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

		// specify texture as color attachment
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
	}

	public function bindFrameBuffer()
	{
		if (GLUtils.invalid(texture) || GLUtils.invalid(framebuffer))
		{
			destroy();
			build();
		}
		else if (HXP.screen.width != _width || HXP.screen.height != _height)
		{
			resize();
		}

		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		GL.clearColor(0, 0, 0, 0);
		GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}
}
