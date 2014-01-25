package com.haxepunk.utils;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Json;
import haxe.io.BytesOutput;
import haxe.io.Eof;
import sys.io.Process;
#end

class HaxelibInfoBuilder
{
	macro public static function build () : Array<Field>
	{
		// Get HaxePuk path
		var output = "";
		
		try
		{
			var process = new Process("haxelib", ["path", "HaxePunk"]);
			var buffer = new BytesOutput();
			
			var waiting = true;
			while (waiting)
			{
				try
				{
					var current = process.stdout.readAll (1024);
                    buffer.write(current);
                    
                    if (current.length == 0)
						waiting = false;
				}
				catch (e:Eof)
				{
					waiting = false;
				}
			}
			
			process.close();
			output = buffer.getBytes().toString();
		}
		catch (e:Dynamic) { }
		
		var lines = output.split("\n");
		var result = "";
		
		for (i in 1...lines.length)
		{				
			if (StringTools.trim(lines[i]) == "-D HaxePunk")
			{
				result = StringTools.trim (lines[i - 1]);
			}	
		}
		
		// Read haxelib.json
		var doc = 
			try Json.parse(sys.io.File.read(result + "haxelib.json").readAll().toString()) 
			catch (e:Dynamic) { };
		
		// Construct fields
		var fields:Array<Field> = Context.getBuildFields();
		
		for (field in Reflect.fields(doc))
		{
			var value = Reflect.field(doc, field);
			
			// Simple String value
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
				// Array<String> value
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
				// Other, probably a Map<String, String>
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
