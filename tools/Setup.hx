import com.haxepunk.utils.HaxelibInfo;

class Setup
{
	public static function installDependencies ()
	{
		for (field in Reflect.fields(HaxelibInfo.install))
		{
			Sys.command("haxelib install " + field + " " + Reflect.field(HaxelibInfo.install, field));
		}
		
		Sys.command("haxelib run lime setup");
	}
}
