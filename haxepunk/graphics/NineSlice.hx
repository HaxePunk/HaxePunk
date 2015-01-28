package haxepunk.graphics;

import haxepunk.graphics.Image;
import haxepunk.math.*;
import haxepunk.scene.Camera;

class NineSlice extends Image
{

	public function new(source:ImageSource, ?clipRect:Rectangle)
	{
		super(source);

		var texture = material.firstPass.getTexture(0);

		_clipRect = (clipRect == null ? new Rectangle(0, 0, texture.width / 3, texture.height / 3) : clipRect);

		if (Std.is(texture, TextureAtlas))
		{
			var atlas = cast(texture, TextureAtlas);
			_topLeft      = atlas.addTile(_clipRect.x, _clipRect.y, _clipRect.width, _clipRect.height);
			_topCenter    = atlas.addTile(_clipRect.right, _clipRect.y, _clipRect.width, _clipRect.height);
			_topRight     = atlas.addTile(_clipRect.x + _clipRect.width * 2, _clipRect.y, _clipRect.width, _clipRect.height);
			_centerLeft   = atlas.addTile(_clipRect.x, _clipRect.bottom, _clipRect.width, _clipRect.height);
			_centerCenter = atlas.addTile(_clipRect.x + _clipRect.width, _clipRect.y + _clipRect.height, _clipRect.width, _clipRect.height);
			_centerRight  = atlas.addTile(_clipRect.x + _clipRect.width * 2, _clipRect.bottom, _clipRect.width, _clipRect.height);
			_bottomLeft   = atlas.addTile(_clipRect.x, _clipRect.y + _clipRect.height * 2, _clipRect.width, _clipRect.height);
			_bottomCenter = atlas.addTile(_clipRect.right, _clipRect.y + _clipRect.height * 2, _clipRect.width, _clipRect.height);
			_bottomRight  = atlas.addTile(_clipRect.x + _clipRect.width * 2, _clipRect.y + _clipRect.height * 2, _clipRect.width, _clipRect.height);
		}
		else
		{
			throw "Must pass a TextureAtlas instance as first texture in material";
		}
	}

	public function setSize(width:Float, height:Float)
	{
		this.width = width;
		this.height = height;
	}

	override public function draw(camera:Camera, offset:Vector3):Void
	{
		var xScale = (width - _clipRect.width * 2) / _clipRect.width;
		var yScale = (height - _clipRect.height * 2) / _clipRect.height;

		origin *= scale;
		origin += offset;

		_matrix.identity();
		_matrix.scale(_clipRect.width, _clipRect.height, 1);
		_matrix.translateVector3(origin);
		_matrix.scaleVector3(scale);

		HXP.spriteBatch.draw(material, _matrix, _topLeft);
		_matrix._41 = origin.x + width - _clipRect.width;
		HXP.spriteBatch.draw(material, _matrix, _topRight);

		_matrix._41 = origin.x;
		_matrix._42 = origin.y + height - _clipRect.height;
		HXP.spriteBatch.draw(material, _matrix, _bottomLeft);
		_matrix._41 = origin.x + width - _clipRect.width;
		HXP.spriteBatch.draw(material, _matrix, _bottomRight);

		_matrix._11 *= xScale;
		_matrix._21 *= xScale;
		_matrix._31 *= xScale;

		_matrix._41 = origin.x + _clipRect.width;
		_matrix._42 = origin.y;
		HXP.spriteBatch.draw(material, _matrix, _topCenter);
		_matrix._42 = origin.y + height - _clipRect.height;
		HXP.spriteBatch.draw(material, _matrix, _bottomCenter);

		_matrix._12 *= yScale;
		_matrix._22 *= yScale;
		_matrix._32 *= yScale;

		_matrix._42 = origin.y + _clipRect.height;
		HXP.spriteBatch.draw(material, _matrix, _centerCenter);

		// reset width scale (maybe save the values and reset?)
		_matrix._11 /= xScale;
		_matrix._21 /= xScale;
		_matrix._31 /= xScale;

		_matrix._41 = origin.x;
		_matrix._42 = origin.y + _clipRect.height;
		HXP.spriteBatch.draw(material, _matrix, _centerLeft);
		_matrix._41 = origin.x + width - _clipRect.width;
		HXP.spriteBatch.draw(material, _matrix, _centerRight);

		origin -= offset;
		origin /= scale;
	}

	private var _topLeft:Int;
	private var _topCenter:Int;
	private var _topRight:Int;
	private var _centerLeft:Int;
	private var _centerCenter:Int;
	private var _centerRight:Int;
	private var _bottomLeft:Int;
	private var _bottomCenter:Int;
	private var _bottomRight:Int;
	private var _clipRect:Rectangle;

}
