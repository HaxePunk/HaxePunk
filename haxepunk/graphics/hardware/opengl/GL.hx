package haxepunk.graphics.hardware.opengl;

#if lime
typedef GL = lime.graphics.opengl.GL;
#elseif nme
typedef GL = flash.gl.GL;
#else
class GL
{
	public static inline var TEXTURE0:Int = 0;
	public static inline var ARRAY_BUFFER:Int = 0;
	public static inline var TEXTURE_2D:Int = 0;
	public static inline var TEXTURE_MIN_FILTER:Int = 0;
	public static inline var TEXTURE_MAG_FILTER:Int = 0;
	public static inline var TEXTURE_WRAP_S:Int = 0;
	public static inline var TEXTURE_WRAP_T:Int = 0;
	public static inline var LINEAR:Int = 0;
	public static inline var NEAREST:Int = 0;
	public static inline var FLOAT:Int = 0;
	public static inline var UNSIGNED_BYTE:Int = 0;
	public static inline var FRAMEBUFFER:Int = 0;
	public static inline var RGBA:Int = 0;
	public static inline var COLOR_ATTACHMENT0:Int = 0;
	public static inline var COLOR_BUFFER_BIT:Int = 0;
	public static inline var DEPTH_BUFFER_BIT:Int = 0;
	public static inline var FUNC_ADD:Int = 0;
	public static inline var FUNC_REVERSE_SUBTRACT:Int = 0;
	public static inline var ONE:Int = 0;
	public static inline var ZERO:Int = 0;
	public static inline var TRIANGLES:Int = 0;
	public static inline var DST_COLOR:Int = 0;
	public static inline var ONE_MINUS_SRC_ALPHA:Int = 0;
	public static inline var ONE_MINUS_SRC_COLOR:Int = 0;
	public static inline var SCISSOR_TEST:Int = 0;
	public static inline var DYNAMIC_DRAW:Int = 0;
	public static inline var STATIC_DRAW:Int = 0;
	public static inline var CLAMP_TO_EDGE:Int = 0;
	public static inline var FRAGMENT_SHADER:Int = 0;
	public static inline var VERTEX_SHADER:Int = 0;

	public static function enable(_) {}
	public static function disable(_) {}
	public static function uniformMatrix4fv(_, _, _) {}
	public static function activeTexture(_) {}
	public static function deleteTexture(_) {}
	public static function createTexture():GLTexture { return 0; }
	public static function texImage2D(_, _, _, _, _, _, _, _, _) {}
	public static function framebufferTexture2D(_, _, _, _, _) {}
	public static function clearColor(_, _, _, _) {}
	public static function clear(_) {}
	public static function scissor(_, _, _, _) {}
	public static function texParameteri(_, _, _) {}
	public static function createBuffer():GLBuffer { return 0; }
	public static function bindBuffer(_, _) {}
	public static function bindFramebuffer(_, _) {}
	public static function bufferData(_, _, _) {}
	public static function bufferSubData(_, _, _) {}
	public static function getUniformLocation(_, _):GLUniformLocation { return 0; }
	public static function uniform1f(_, _) {}
	public static function uniform1i(_, _) {}
	public static function uniform2f(_, _, _) {}
	public static function compileShader(_) {}
	public static function createShader(_):GLShader { return 0; }
	public static function createProgram():GLProgram { return 0; }
	public static function createFramebuffer():GLFramebuffer { return 0; }
	public static function shaderSource(_, _) {}
	public static function attachShader(_, _) {}
	public static function linkProgram(_) {}
	public static function useProgram(_) {}
	public static function enableVertexAttribArray(_) {}
	public static function disableVertexAttribArray(_) {}
	public static function getAttribLocation(_, _) {}
	public static function vertexAttribPointer(_, _, _, _, _, _) {}
	public static function blendEquation(_) {}
	public static function blendEquationSeparate(_, _) {}
	public static function blendFunc(_, _) {}
	public static function blendFuncSeparate(_, _, _, _) {}
	public static function drawArrays(_, _, _) {}
	public static function bindTexture(_, _) {}
}
#end
