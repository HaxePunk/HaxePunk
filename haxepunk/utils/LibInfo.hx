package haxepunk.utils;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Json;
import haxe.io.BytesOutput;
import haxe.io.Eof;
import sys.io.Process;
#end

private typedef LibInfoType = { 
	name:String, 
	url:String, 
	license:String, 
	tags:Array<String>, 
	description:String, 
	version:String, 
	releasenote:String, 
	contributors:Array<String>, 
	dependencies:Map<String, String>
};

class LibInfoBuilder
{
	macro public static function build():Array<Field>
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
				result = StringTools.trim(lines[i - 1]);
			}
		}

		// Read haxelib.json
		var doc:LibInfoType = try {
			Json.parse(sys.io.File.read(result + "haxelib.json").readAll().toString());
		} catch (e:Dynamic) { trace(e); null;}

		// Construct fields
		var fields:Array<Field> = Context.getBuildFields();
		
		// Simple String value
		for (field in ["name", "url", "license", "description", "version", "releasenote"])
		{
			var value:String = Reflect.field(doc, field);
			
			fields.push({
				name: field,
				doc: null,
				meta: [],
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{value}),
				pos: Context.currentPos()
			});
		}
			
		// Array<String> value
		for (field in ["tags", "contributors"])
		{
			var value:Array<String> = Reflect.field(doc, field);
			
			fields.push({
				name: field,
				doc: null,
				meta: [],
				access: [Access.APublic, Access.AStatic],
				kind: FieldType.FProp("default", "never", macro:Array<String>, macro $v{value}),
				pos: Context.currentPos()
			});
		}
		
		// Map<String, String> value
		fields.push({
			name: "dependencies",
			doc: null,
			meta: [],
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FVar(macro:Dynamic, macro $v{doc.dependencies}),
			pos: Context.currentPos()
		});

		return fields;
	}
}

#if !macro @:build(haxepunk.utils.LibInfo.LibInfoBuilder.build()) #end
class LibInfo
{
}
