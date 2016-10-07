package com.haxepunk.utils;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Json;
import haxe.io.Path;
#end

@:dox(hide)
class HaxelibInfoBuilder
{
	macro public static function build():Array<Field>
	{
		var path = haxe.macro.Context.resolvePath("com/haxepunk/utils/HaxelibInfo.hx");
		path = Path.normalize(Path.directory(path) + "/../../../haxelib.json");

		// Read haxelib.json
		var doc:Dynamic = null;
		try
		{
			doc = Json.parse(sys.io.File.read(path).readAll().toString());
		}
		catch (e:Dynamic)
		{
			trace(e);
		}

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
					kind: FieldType.FVar(macro:String, macro $v{value}),
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
						kind: FieldType.FVar(macro:Array<String>, macro $v{value}),
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
						kind: FieldType.FVar(macro:Dynamic, macro $v{value}),
						pos: Context.currentPos()
					});
				}
			}
		}

		return fields;
	}
}

#if !macro @:build(com.haxepunk.utils.HaxelibInfoBuilder.build()) #end
/**
 * Access HaxePunk's haxelib.json from your code.
 */
class HaxelibInfo {}
