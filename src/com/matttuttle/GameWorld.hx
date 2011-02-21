package com.matttuttle;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.World;

import com.haxepunk.graphics.PreRotation;
import com.haxepunk.graphics.Stamp;
//import com.haxepunk.graphics.Tilemap;
//import com.haxepunk.graphics.TiledImage;
//import com.haxepunk.graphics.TiledSpritemap;

class GameWorld extends World
{
	
	private var pr:PreRotation;
	
	public function new()
	{
		super();
		HXP.screen.color = 0x8EDFFA;
		
		var e:Entity = new Entity();
		e.x = e.y = 100;
		pr = new PreRotation(Assets.GfxBlock);
		pr.frameAngle = 45;
		e.graphic = pr;
		add(e);
		
		add(new Character(HXP.screen.width / 2, HXP.screen.height - 64));
		
		// Fill with blocks
		var i:Int;
		for (i in 0...Std.int(HXP.screen.width / 32))
		{
			add(new Block(i * 32, HXP.screen.height - 32));
		}
	}
	
	override public function update()
	{
		pr.frameAngle += 5;
	}
	
}