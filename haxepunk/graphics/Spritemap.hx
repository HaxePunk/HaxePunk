package haxepunk.graphics;

import lime.gl.GL;
import lime.gl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.Matrix3D;
import lime.utils.Vector3D;
import haxe.Timer;

class Spritemap extends Image
{

	public var columns(default, null):Int;
	public var rows(default, null):Int;
	public var frames(default, null):Int;

	public function new(path:String, width:Int, height:Int)
	{
		super(path);
		_spriteWidth = width;
		_spriteHeight = height;
		_time = Timer.stamp();
	}

	override private function initBuffer():Void
	{
		_texture.onload = function() {
			columns = Math.ceil(_texture.originalWidth / _spriteWidth);
			rows = Math.ceil(_texture.originalHeight / _spriteHeight);
			frames = columns * rows;
			var data = new Array<Float>();
			var xx = (_spriteWidth / _texture.originalWidth) * (_texture.originalWidth / _texture.width);
			var yy = (_spriteHeight / _texture.originalHeight) * (_texture.originalHeight / _texture.height);
			var i = 0;
			for (y in 0...rows)
			{
				for (x in 0...columns)
				{
					data[i++] = 0; // vert
					data[i++] = 0;
					data[i++] = 0;
					data[i++] = x * xx; // tex
					data[i++] = y * yy;
					// normal (0, 0, -1)
					data[i++] = data[i++] = 0; data[i++] = -1;

					data[i++] = 0; // vert
					data[i++] = 1;
					data[i++] = 0;
					data[i++] = x * xx; // tex
					data[i++] = (y + 1) * yy;
					// normal (0, 0, -1)
					data[i++] = data[i++] = 0; data[i++] = -1;

					data[i++] = 1; // vert
					data[i++] = 0;
					data[i++] = 0;
					data[i++] = (x + 1) * xx; // tex
					data[i++] = y * yy;
					// normal (0, 0, -1)
					data[i++] = data[i++] = 0; data[i++] = -1;

					data[i++] = 1; // vert
					data[i++] = 1;
					data[i++] = 0;
					data[i++] = (x + 1) * xx; // tex
					data[i++] = (y + 1) * yy;
					// normal (0, 0, -1)
					data[i++] = data[i++] = 0; data[i++] = -1;
				}
			}
			_buffer = GL.createBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, _buffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(cast data), GL.STATIC_DRAW);
		}
	}

	override public function draw(projectionMatrix:Matrix3D, modelViewMatrix:Matrix3D):Void
	{
		if (_buffer == null) return;
		modelViewMatrix.prependRotation(angle, Vector3D.Z_AXIS);
		modelViewMatrix.prependScale(scale * scaleX, scale * scaleY, 1);
		modelViewMatrix.prependTranslation(originX, originY, 0);
		modelViewMatrix.prependScale(_spriteWidth, _spriteHeight, 1);

		GL.bindBuffer(GL.ARRAY_BUFFER, _buffer);
		material.use(projectionMatrix, modelViewMatrix);
		GL.drawArrays(GL.TRIANGLE_STRIP, _bufferOffset * 4, 4);
		material.disable();
		GL.bindBuffer(GL.ARRAY_BUFFER, null);

		var now = Timer.stamp();
		if (now - _time > 0.1)
		{
			_bufferOffset += 1;
			if (_bufferOffset > frames) _bufferOffset = 0;
			_time = now;
		}
	}

	private var _buffer:GLBuffer;
	private var _bufferOffset:Int = 0;
	private var _spriteWidth:Float = 0;
	private var _spriteHeight:Float = 0;
	private var _time:Float = 0;

}
