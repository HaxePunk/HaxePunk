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

		_topLeft      = _clipRect;
		_topCenter    = new Rectangle(_clipRect.right, _clipRect.y, _clipRect.width, _clipRect.height);
		_topRight     = new Rectangle(_clipRect.x + _clipRect.width * 2, _clipRect.y, _clipRect.width, _clipRect.height);
		_centerLeft   = new Rectangle(_clipRect.x, _clipRect.bottom, _clipRect.width, _clipRect.height);
		_centerCenter = new Rectangle(_clipRect.x + _clipRect.width, _clipRect.y + _clipRect.height, _clipRect.width, _clipRect.height);
		_centerRight  = new Rectangle(_clipRect.x + _clipRect.width * 2, _clipRect.bottom, _clipRect.width, _clipRect.height);
		_bottomLeft   = new Rectangle(_clipRect.x, _clipRect.y + _clipRect.height * 2, _clipRect.width, _clipRect.height);
		_bottomCenter = new Rectangle(_clipRect.right, _clipRect.y + _clipRect.height * 2, _clipRect.width, _clipRect.height);
		_bottomRight  = new Rectangle(_clipRect.x + _clipRect.width * 2, _clipRect.y + _clipRect.height * 2, _clipRect.width, _clipRect.height);
	}

	public function setSize(width:Float, height:Float)
	{
		this.width = width;
		this.height = height;
	}

	override public function draw(offset:Vector3):Void
	{
		var stretchWidth = width - _clipRect.width * 2;
		var stretchHeight = height - _clipRect.height * 2;

		var x1 = offset.x + _clipRect.width;
		var x2 = offset.x + width - _clipRect.width;

		var y = offset.y;
		SpriteBatch.draw(material, offset.x, y, _topLeft.width, _topLeft.height,
			_topLeft.x, _topLeft.y, _topLeft.width, _topLeft.height, false, false,
			origin.x, origin.y, scale.x, scale.y);
		SpriteBatch.draw(material, x1, y, stretchWidth, _topCenter.height,
			_topCenter.x, _topCenter.y, _topCenter.width, _topCenter.height, false, false,
			origin.x, origin.y, scale.x, scale.y);
		SpriteBatch.draw(material, x2, y, _topRight.width, _topRight.height,
			_topRight.x, _topRight.y, _topRight.width, _topRight.height, false, false,
			origin.x, origin.y, scale.x, scale.y);

		y = offset.y + _clipRect.height;
		SpriteBatch.draw(material, offset.x, y, _centerLeft.width, stretchHeight,
			_centerLeft.x, _centerLeft.y, _centerLeft.width, _centerLeft.height, false, false,
			origin.x, origin.y, scale.x, scale.y);
		SpriteBatch.draw(material, x1, y, stretchWidth, stretchHeight,
			_centerCenter.x, _centerCenter.y, _centerCenter.width, _centerCenter.height, false, false,
			origin.x, origin.y, scale.x, scale.y);
		SpriteBatch.draw(material, x2, y, _centerRight.width, stretchHeight,
			_centerRight.x, _centerRight.y, _centerRight.width, _centerRight.height, false, false,
			origin.x, origin.y, scale.x, scale.y);

		y = offset.y + height - _clipRect.height;
		SpriteBatch.draw(material, offset.x, y, _bottomLeft.width, _bottomLeft.height,
			_bottomLeft.x, _bottomLeft.y, _bottomLeft.width, _bottomLeft.height, false, false,
			origin.x, origin.y, scale.x, scale.y);
		SpriteBatch.draw(material, x1, y, stretchWidth, _bottomCenter.height,
			_bottomCenter.x, _bottomCenter.y, _bottomCenter.width, _bottomCenter.height, false, false,
			origin.x, origin.y, scale.x, scale.y);
		SpriteBatch.draw(material, x2, y, _bottomRight.width, _bottomRight.height,
			_bottomRight.x, _bottomRight.y, _bottomRight.width, _bottomRight.height, false, false,
			origin.x, origin.y, scale.x, scale.y);
	}

	private var _topLeft:Rectangle;
	private var _topCenter:Rectangle;
	private var _topRight:Rectangle;
	private var _centerLeft:Rectangle;
	private var _centerCenter:Rectangle;
	private var _centerRight:Rectangle;
	private var _bottomLeft:Rectangle;
	private var _bottomCenter:Rectangle;
	private var _bottomRight:Rectangle;

}
