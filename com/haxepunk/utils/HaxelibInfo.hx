package com.haxepunk.utils;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Json;

class HaxelibInfoBuilder
{
	macro public static function build () : Array<Field>
	{
		var doc = 
			try Json.parse(sys.io.File.read("../haxelib.json").readAll().toString()) 
			catch (e:Dynamic) {};
		
		var fields:Array<Field> = Context.getBuildFields();
		
		for (field in Reflect.fields(doc))
		{
			var value = Reflect.field(doc, field);
			
			if (Std.is(value, String))
			{				
				fields.push({
					name: field,
					doc: null,
					meta: [],
					access: [Access.APublic, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro : String, macro $v{value}),
					pos: Context.currentPos()
				});
			}
			else
			{
				if (Type.getClassName(Type.getClass(value)) == "Array")
				{					
					fields.push({
						name: field,
						doc: null,
						meta: [],
						access: [Access.APublic, Access.AStatic],
						kind: FieldType.FVar(macro : Array<String>, macro $v{value}),
						pos: Context.currentPos()
					});
				}			
				else
				{					
					fields.push({
						name: field,
						doc: null,
						meta: [],
						access: [Access.APublic, Access.AStatic],
						kind: FieldType.FVar(macro : Dynamic, macro $v{value}),
						pos: Context.currentPos()
					});
				}
			}
		}		
				
		return fields;
	}
}

#if !macro @:build(com.haxepunk.utils.HaxelibInfoBuilder.build()) #end
class HaxelibInfo
{
}
