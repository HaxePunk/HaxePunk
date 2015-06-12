package com.haxepunk.graphics.atlas;
import com.haxepunk.Scene;
import openfl.display.Tilesheet;

class DrawState
{
	private static var poolHead:DrawState;
	private static var poolTail:DrawState;
	
	private static var drawHead:DrawState;
	private static var drawTail:DrawState;
	
	private static function getState(tilesheet:Tilesheet, rgb:Bool, alpha:Bool, smooth:Bool, blend:Int):DrawState
	{
		var state:DrawState = null;
		
		if (poolHead != null)
		{
			state = poolHead;
			poolHead = state.next;
			
			if (poolHead == null)
			{
				poolTail = null;
			}
		}
		else
		{
			state = new DrawState();
		}
		
		state.set(tilesheet, rgb, alpha, smooth, blend);
		return state;
	}
	
	private static function putState(state:DrawState):Void
	{
		if (poolTail != null)
		{
			poolTail.next = state;
			poolTail = state;
		}
		else
		{
			poolHead = poolTail = state;
		}
	}
	
	public static function drawStates(scene:Scene):Void
	{
		var next:DrawState = drawHead;
		var state:DrawState;
		
		while (next != null)
		{
			state = next;
			next = state.next;
			state.render(scene);
			state.reset();
		}
		
		drawHead = null;
		drawTail = null;
	}
	
	public static function getDrawState(tilesheet:Tilesheet, rgb:Bool, alpha:Bool, smooth:Bool, blend:Int):DrawState
	{
		var state:DrawState = null;
		if (drawTail != null)
		{
			if (drawTail.tilesheet == tilesheet && drawTail.rgb == rgb && drawTail.alpha == alpha && drawTail.smooth == smooth && drawTail.blend == blend)
			{
				return drawTail;
			}
			else
			{
				state = getState(tilesheet, rgb, alpha, smooth, blend);
				drawTail.next = state;
				drawTail = state;
			}
		}
		else
		{
			state = getState(tilesheet, rgb, alpha, smooth, blend);
			drawTail = drawHead = state;
		}
		
		return state;
	}
	
	public var tilesheet:Tilesheet;
	public var data:Array<Float>;
	public var dataIndex:Int = 0;
	public var alpha:Bool = false;
	public var rgb:Bool = false;
	public var smooth:Bool = false;
	public var blend:Int = 0;
	
	public var next:DrawState;
	
	public function new() 
	{
		data = [];
	}
	
	public inline function reset():Void
	{
		dataIndex = 0;
		tilesheet = null;
		next = null;
		
		DrawState.putState(this);
	}
	
	public inline function set(tilesheet:Tilesheet, rgb:Bool, alpha:Bool, smooth:Bool, blend:Int):Void
	{
		this.tilesheet = tilesheet;
		this.rgb = rgb;
		this.alpha = alpha;
		this.smooth = smooth;
		this.blend = blend;
	}
	
	public inline function render(scene:Scene):Void
	{
		var flags:Int = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RECT | blend;
		if (rgb) flags |= Tilesheet.TILE_RGB;
		if (alpha) flags |= Tilesheet.TILE_ALPHA;
		
		tilesheet.drawTiles(scene.sprite.graphics, data, smooth, flags, dataIndex);
		dataIndex = 0;
	}
}