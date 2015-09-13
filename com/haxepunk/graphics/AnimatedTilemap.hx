package com.haxepunk.graphics;

import com.haxepunk.Graphic.TileType;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.HXP;

/**
 * Tilemap addition to enable defining animated tiles.
 * @author voec
 */
class AnimatedTilemap extends Tilemap
{
	
	/**
	 * Animation speed factor, alter this to speed up/slow down all animations.
	 */
	public var rate:Float;
	
	/**
	 * Constructor.
	 * @param	tileset				The source tileset image.
	 * @param	width				Width of the tilemap, in pixels.
	 * @param	height				Height of the tilemap, in pixels.
	 * @param	tileWidth			Tile width.
	 * @param	tileHeight			Tile height.
	 * @param	tileSpacingWidth	Tile horizontal spacing.
	 * @param	tileSpacingHeight	Tile vertical spacing.
	 * @param	opaqueTiles			Indicates if this tileset contains only opaque tiles (defaults to true). Only used in Flash .
	 */
	public function new(tileset:TileType, width:Int, height:Int, tileWidth:Int, tileHeight:Int, ?tileSpacingWidth:Int=0, ?tileSpacingHeight:Int=0, ?opaqueTiles:Bool=true) 
	{
		
		super(tileset, width, height, tileWidth, tileHeight, tileSpacingWidth, tileSpacingHeight, opaqueTiles);
		
		rate = 1;
		
		active = true;
		
	}
	
	/** @private Updates the animation. */
	override public function update()
	{
		
		if (_anims != null)
		{
			var a:Int;
			//go through each animation in _anims array
			for (a in 0..._anims.length)
			{
				
				_anims[a]._timer += (HXP.fixed ? _anims[a]._frameRate / HXP.assignedFrameRate : _anims[a]._frameRate * HXP.elapsed) * rate;
				
				if (_anims[a]._timer >= 1)
				{
					while (_anims[a]._timer >= 1)
					{
						_anims[a]._timer -= 1;
						_anims[a]._index += 1; //increase frame index
						
						//if last index -> go back to first frame (loop)
						if (_anims[a]._index == _anims[a]._frames.length)
						{
							_anims[a]._index = 0;
						}
					}
					
					var b:Int;
					//for each tile that needs to be animated
					for (b in 0..._anims[a]._tiles.length)
					{
						setTile(Std.int(_anims[a]._tiles[b] % columns), Std.int(_anims[a]._tiles[b] / columns), _anims[a]._frames[_anims[a]._index]);
						//I don't even...	
					}
					
					
				}
			}
		}
		
		super.update();
		
		
	}
	
	/**
	 * Add an animation to tiles in the Tilemap.
	 * @param	frames		Array of frame indices to animate through. The first frame should be the 1D index of the tile used when drawing the tilemap.
	 * @param	frameRate	Animation speed (in frames per second, 0 defaults to assigned frame rate)
	 */
	public function animate(frames:Array<Int>, frameRate:Float = 0):Void
	{
		
		// Search through tilemap for all tiles that need to be animated and mark them down in array
		var x:Int; var y:Int;
		var tiles:Array<Int> = new Array();
		for (y in 0...rows)
		{
			for (x in 0...columns)
			{
				if (getTile(x, y) == frames[0]) tiles.push(x + (y * columns));
				//x + (y * columns) -> getting the 1D index of a tile in the tilemap
			}
		}
		
		// Add to _anims array
		_anims.push(new Animation(frames, frameRate, tiles));
		
	}
	
	//Create an array to hold all the animations
	private var _anims:Array<Animation> = new Array();
	
	
}

private class Animation
{
    public var _frames:Array<Int>;
    public var _frameRate:Float;
    public var _tiles:Array<Int>;
	public var _timer:Float;
	public var _index:Int;

	/**
	 * Little helper class for defining animations.
	 */
    public function new(frames:Array<Int>, frameRate:Float, tiles:Array<Int>)
    {
        _frames = frames;
		_frameRate = frameRate;
		_tiles = tiles;
		_timer = 0;
		_index = 0;

    }

}
