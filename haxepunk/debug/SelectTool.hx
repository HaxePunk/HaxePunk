package haxepunk.debug;

import haxepunk.graphics.Draw;
import haxepunk.inputs.Input;
import haxepunk.inputs.Mouse;
import haxepunk.math.Rectangle;
import haxepunk.math.Vector3;
import haxepunk.scene.Scene;

class SelectTool implements Tool
{

	public function new()
	{
		_selectRect = new Rectangle();
	}

	public function update(scene:Scene, elapsed:Float)
	{
		if (Input.pressed(MouseButton.LEFT) > 0)
		{
			_mouseOriginX = _selectRect.x = Mouse.x;
			_mouseOriginY = _selectRect.y = Mouse.y;
			_selectRect.width = _selectRect.height = 0;
			_mousePressed = true;
		}
		else if (Input.released(MouseButton.LEFT) > 0)
		{
			_mousePressed = false;
			// HXP.scene.entities();
		}
		else if (Input.check(MouseButton.LEFT))
		{
			if (Mouse.x < _mouseOriginX)
			{
				_selectRect.x = Mouse.x;
				_selectRect.right = _mouseOriginX;
			}
			else
			{
				_selectRect.x = _mouseOriginX;
				_selectRect.right = Mouse.x;
			}

			if (Mouse.y < _mouseOriginY)
			{
				_selectRect.y = Mouse.y;
				_selectRect.bottom = _mouseOriginY;
			}
			else
			{
				_selectRect.y = _mouseOriginY;
				_selectRect.bottom = Mouse.y;
			}
		}
	}

	public function draw(cameraPosition:Vector3)
	{
		if (_mousePressed)
		{
			Draw.rect(_selectRect.x + cameraPosition.x, _selectRect.y + cameraPosition.y, _selectRect.width, _selectRect.height, HXP.selectColor);
		}
	}

	private var _selectRect:Rectangle;
	private var _mouseOriginX:Float = 0;
	private var _mouseOriginY:Float = 0;
	private var _mousePressed:Bool = false;
}
