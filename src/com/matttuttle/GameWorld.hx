package com.matttuttle;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.World;

import com.haxepunk.Sfx;

class GameWorld extends World
{
	
	public function new()
	{
		super();
		HXP.screen.color = 0x8EDFFA;
		
		add(new Character(HXP.screen.width / 2, HXP.screen.height - 64));
		
		// Fill with blocks
		var i:Int;
		for (i in 0...Std.int(HXP.screen.width / 32))
		{
			add(new Block(i * 32, HXP.screen.height - 32));
		}
	}
	
}