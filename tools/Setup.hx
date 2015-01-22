package tools;

import haxepunk.utils.LibInfo;

class Setup
{
	public static function setup()
	{
		installDependencies();
		Sys.command('haxelib run $LIME setup');
	}

	public static function update()
	{
		Sys.command("haxelib update HaxePunk");
		installDependencies();
	}

	public static function installDependencies()
	{
		// for (field in Reflect.fields(LibInfo.install))
		// {
		// 	Sys.command("haxelib install " + field + " " + Reflect.field(LibInfo.install, field));
		// }
	}

	private static inline var LIME = "aether";
}
