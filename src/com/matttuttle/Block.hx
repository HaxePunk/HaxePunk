package com.matttuttle;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Block extends Entity
{
	
	public function new(x:Int, y:Int) 
	{
		super(x, y);
		
		graphic = new Image(Assets.GfxBlock);
		setHitbox(32, 32);
		
		// This block is collidable with a physics character
		type = "solid";
	}
	
}