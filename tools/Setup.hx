import haxepunk.utils.HaxelibInfo;

class Setup
{
	public static function setup()
	{
		installDependencies();
		Sys.command("haxelib", ["run", OPENFL, "setup"]);
	}

	public static function update()
	{
		Sys.command("haxelib", ["update", "HaxePunk"]);
		installDependencies();
	}

	public static function installDependencies()
	{
		for (field in Reflect.fields(HaxelibInfo.install))
		{
			var version = Reflect.field(HaxelibInfo.install, field),
				args = if(version != "") ["install", field, version]
					else ["install", field];
			Sys.command("haxelib", args);
		}
	}

	static inline var OPENFL = "lime";
}
