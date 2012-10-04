import haxe.io.Bytes;
import haxe.io.BytesInput;
import neko.Lib;
import neko.FileSystem;
import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.io.Path;
import neko.zip.Reader;

class SetupTool
{

	public function new()
	{
		var args:Array<String> = neko.Sys.args();
		if (args.length < 2)
		{
			usage();
			return;
		}

		// defaults
		projectName  = "";
        projectClass = "Main";
        width        = "640";
        height       = "480";
        rate         = "30";

		var command:String = args.shift();

		switch (command)
		{
			case "new":
				newProject(args);
			case "help":
				usage();
		}
	}

	public function usage()
	{
		Lib.println("USAGE: haxelib run HaxePunk new [-s WIDTHxHEIGHT] [-r FRAMERATE] [-c CLASS_NAME] [PROJECT_NAME]");
	}

	public function newProject(args:Array<String>)
	{
		var slash:String = "";

		var path = args.pop();

		// parse command line arguments
		var length = args.length;
		var i = 0;
		while (i < length)
		{
			switch (args[i])
			{
				case '-s':
					i += 1;
					var size = args[i].split('x');
					width = size[0];
					height = size[1];

				case '-r':
					i += 1;
					rate = args[i];

				case '-c':
					projectClass = args[i].charAt(0).toUpperCase() + args[i].substr(1).toLowerCase();

				default:
					projectName = args[i];
					path += projectName + '/';
			}
			i += 1;
		}

		createDirectory(path);

		if (FileSystem.isDirectory(path))
		{
			// read the template zip file
			var templateZip = File.read("template.zip", true);
			var entries = Reader.readZip(templateZip);
			templateZip.close();

			// unzip the file
			for (entry in entries)
			{
				var filename:String = entry.fileName;

				// check if it's a folder
				if (StringTools.endsWith(filename, "/") || StringTools.endsWith(filename, "\\"))
				{
					Lib.println(filename);

					createDirectory(path + "/" + filename);
				}
				else
				{
					// create the file
					var bytes:Bytes = Reader.unzip(entry);

					if (StringTools.endsWith(filename, ".hx") || StringTools.endsWith(filename, ".nmml"))
					{
						var text:String = new BytesInput(bytes).readString(bytes.length);

						text = runTemplate(text);

						bytes = Bytes.ofString(text);

						filename = runTemplate(filename);
					}

					Lib.println(filename);

					var fout:FileOutput = File.write(path + "/" + filename, true);
					fout.writeBytes(bytes, 0, bytes.length);
					fout.close();
				}
			}
		}
		else
		{
			Lib.println("You must provide a directory");
			usage();
		}
	}

	/**
	 * Creates a directory if it doesn't already exist
	 */
	private function createDirectory(path:String)
	{
		path = new Path(path).dir;

		if (!FileSystem.exists(path))
		{
			FileSystem.createDirectory(path);
		}
	}

	private function runTemplate(text:String):String
	{
		text = StringTools.replace(text, "{{PROJECT_NAME}}", projectName);
		text = StringTools.replace(text, "{{PROJECT_CLASS}}", projectClass);
		text = StringTools.replace(text, "{{WIDTH}}", width);
		text = StringTools.replace(text, "{{HEIGHT}}", height);
		text = StringTools.replace(text, "{{FRAMERATE}}", rate);

		return text;
	}

	public static function main()
	{
		new SetupTool();
	}

	private var projectName:String;
	private var projectClass:String;
	private var width:String;
	private var height:String;
	private var rate:String;

}