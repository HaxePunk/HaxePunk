package haxepunk.graphics;

import haxepunk.math.*;
import haxepunk.scene.Camera;

class NineSlice extends Image
{

	public function new(asset:GraphicAsset, ?clipRect:Rectangle)
	{
		super(asset);

		if (clipRect == null) clipRect = new Rectangle(0, 0, 1, 1);
		_clipRect = clipRect;

		var texture = material.firstPass.getTexture(0);
		if (Std.is(texture, TextureAtlas))
		{
			var atlas = cast(texture, TextureAtlas);
			_topLeft      = atlas.addTile(clipRect.x, clipRect.y, clipRect.width, clipRect.height);
			_topCenter    = atlas.addTile(clipRect.right, clipRect.y, clipRect.width, clipRect.height);
			_topRight     = atlas.addTile(clipRect.x + clipRect.width * 2, clipRect.y, clipRect.width, clipRect.height);
			_centerLeft   = atlas.addTile(clipRect.x, clipRect.bottom, clipRect.width, clipRect.height);
			_centerCenter = atlas.addTile(clipRect.x + clipRect.width, clipRect.y + clipRect.height, clipRect.width, clipRect.height);
			_centerRight  = atlas.addTile(clipRect.x + clipRect.width * 2, clipRect.bottom, clipRect.width, clipRect.height);
			_bottomLeft   = atlas.addTile(clipRect.x, clipRect.y + clipRect.height * 2, clipRect.width, clipRect.height);
			_bottomCenter = atlas.addTile(clipRect.right, clipRect.y + clipRect.height * 2, clipRect.width, clipRect.height);
			_bottomRight  = atlas.addTile(clipRect.x + clipRect.width * 2, clipRect.y + clipRect.height * 2, clipRect.width, clipRect.height);
		}
		else
		{
			throw "Must pass a TextureAtlas instance as first texture in material";
		}
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
